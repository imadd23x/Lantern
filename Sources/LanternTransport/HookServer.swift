import Foundation
import Darwin
import LanternCore

/// All shared socket state is lock-protected. Callbacks are delivered on background threads.
/// Consumers choose their actor; stop is safe from callbacks and never waits for the accept thread.
public final class HookServer: @unchecked Sendable {
    public let socketPath: String
    private let directory: URL
    private let lock = NSLock()
    private var listener: Int32 = -1
    private var peers: [String: SocketPeer] = [:]
    private var ownsSocket = false
    private var socketIdentity: ino_t = 0

    public init(directory: URL = RuntimeDirectory.current) {
        self.directory = directory; socketPath = directory.appendingPathComponent("lantern.sock").path
    }

    public func start(onEvent: @escaping @Sendable (AgentEvent, String) -> Void,
                      onDisconnect: @escaping @Sendable (String) -> Void,
                      onUsage: @escaping @Sendable (ClaudeUsageSnapshot) -> Void = { _ in }) throws {
        try lock.withLock {
            guard listener < 0 else { throw TransportError.occupied }
            let fm = FileManager.default
            try fm.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            var info = stat()
            guard lstat(directory.path, &info) == 0, (info.st_mode & S_IFMT) == S_IFDIR,
                  info.st_uid == getuid() else { throw TransportError.unsafeDirectory }
            let directoryFD = open(directory.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
            guard directoryFD >= 0 else { throw TransportError.unsafeDirectory }
            defer { close(directoryFD) }
            guard fchmod(directoryFD, 0o700) == 0 else { throw TransportError.unsafeDirectory }
            if lstat(socketPath, &info) == 0 { throw TransportError.occupied }
            var addr = try SocketIO.address(socketPath)
            let fd = socket(AF_UNIX, SOCK_STREAM, 0)
            guard fd >= 0 else { throw TransportError.system(errno) }
            let bound = withUnsafePointer(to: &addr) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    bind(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
                }
            }
            guard bound == 0 else { close(fd); throw TransportError.system(errno) }
            ownsSocket = true
            if lstat(socketPath, &info) == 0 { socketIdentity = info.st_ino }
            guard chmod(socketPath, 0o600) == 0, Darwin.listen(fd, 32) == 0 else {
                close(fd); unlink(socketPath); ownsSocket = false
                throw TransportError.system(errno)
            }
            listener = fd
            Thread.detachNewThread { [self] in acceptLoop(fd: fd, onEvent: onEvent, onDisconnect: onDisconnect, onUsage: onUsage) }
        }
    }

    public func respond(to id: String, with decision: HookDecision) {
        let peer = lock.withLock { peers[id] }
        peer?.finish(decision)
    }

    public func stop() {
        let (fd, connections) = lock.withLock { () -> (Int32, [SocketPeer]) in
            let fd = listener; listener = -1
            return (fd, Array(peers.values))
        }
        // The accept thread closes the listener, preventing descriptor-reuse races.
        if fd >= 0 { shutdown(fd, SHUT_RDWR) }
        for connection in connections { connection.finish(.delegate) }
        lock.withLock {
            var info = stat()
            if ownsSocket, lstat(socketPath, &info) == 0, info.st_ino == socketIdentity { unlink(socketPath) }
            ownsSocket = false
        }
    }

    private func acceptLoop(fd: Int32, onEvent: @escaping @Sendable (AgentEvent, String) -> Void,
                            onDisconnect: @escaping @Sendable (String) -> Void,
                            onUsage: @escaping @Sendable (ClaudeUsageSnapshot) -> Void) {
        defer { close(fd) }
        while lock.withLock({ listener == fd }) {
            let client = accept(fd, nil, nil)
            if client < 0 { if errno == EINTR { continue }; break }
            var uid: uid_t = 0; var gid: gid_t = 0
            guard getpeereid(client, &uid, &gid) == 0, uid == getuid() else { close(client); continue }
            let id = UUID().uuidString
            let peer = SocketPeer(fd: client)
            let accepted = lock.withLock { () -> Bool in
                guard listener == fd, peers.count < 32 else { return false }
                peers[id] = peer; return true
            }
            guard accepted else { peer.closeOwnedDescriptor(); continue }
            Thread.detachNewThread { [self] in
                var pendingApproval = false
                defer {
                    peer.closeOwnedDescriptor()
                    _ = lock.withLock { peers.removeValue(forKey: id) }
                    // Telemetry closes normally after its acknowledgement. Only a pending
                    // approval needs cancellation; actor scheduling must not discard telemetry.
                    if pendingApproval { onDisconnect(id) }
                }
                do {
                    SocketIO.configure(client, timeout: 2)
                    let data = try SocketIO.readLine(client, timeout: 2)
                    let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if root?["type"] != nil {
                        let envelope = try JSONDecoder().decode(ClaudeUsageEnvelope.self, from: data)
                        try envelope.validate()
                        onUsage(envelope.snapshot)
                        peer.finish(.delegate)
                        return
                    }
                    let event = try JSONDecoder().decode(AgentEvent.self, from: data)
                    try event.validate()
                    pendingApproval = event.kind == .approval
                    onEvent(event, id)
                    if event.kind == .approval {
                        // Wait only to detect the relay exiting. A decision shuts down this read.
                        SocketIO.configure(client, timeout: SessionState.approvalLifetime + 2)
                        var byte: UInt8 = 0
                        _ = recv(client, &byte, 1, 0)
                    } else { peer.finish(.delegate) }
                } catch { peer.finish(.delegate) }
            }
        }
    }
}

private final class SocketPeer: @unchecked Sendable {
    private let lock = NSLock()
    private var fd: Int32
    private var finished = false
    init(fd: Int32) { self.fd = fd }
    func finish(_ decision: HookDecision) {
        lock.withLock {
            guard fd >= 0, !finished else { return }
            finished = true
            // Sending after relay EOF can fail normally; never convert failure into allow.
            if let data = try? JSONEncoder().encode(decision) { try? SocketIO.writeLine(data, fd: fd) }
            shutdown(fd, SHUT_RDWR)
        }
    }
    func closeOwnedDescriptor() {
        lock.withLock { if fd >= 0 { close(fd); fd = -1 } }
    }
}
