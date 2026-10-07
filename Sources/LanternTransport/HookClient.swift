import Foundation
import Darwin
import LanternCore

public enum RuntimeDirectory {
    public static var current: URL {
        if let custom = ProcessInfo.processInfo.environment["LANTERN_RUNTIME_DIR"], custom.hasPrefix("/") {
            return URL(fileURLWithPath: custom)
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Lantern")
    }
}

public enum HookClient {
    /// No decision on EOF. Throwing here never means an agent should grant permission.
    public static func exchange(_ event: AgentEvent, socketPath: String,
                                timeout: TimeInterval? = nil) throws -> HookDecision {
        try event.validate()
        return try exchange(JSONEncoder().encode(event), socketPath: socketPath,
                            timeout: timeout ?? (event.kind == .approval ? 115 : 0.3))
    }

    /// A usage acknowledgement can never be an approval, even from an unexpected peer response.
    public static func exchange(_ usage: ClaudeUsageEnvelope, socketPath: String) throws -> HookDecision {
        try usage.validate()
        _ = try exchange(JSONEncoder().encode(usage), socketPath: socketPath, timeout: 0.3)
        return .delegate
    }

    private static func exchange(_ data: Data, socketPath: String, timeout duration: TimeInterval) throws -> HookDecision {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw TransportError.system(errno) }
        defer { close(fd) }
        SocketIO.configure(fd, timeout: duration)
        var addr = try SocketIO.address(socketPath)
        let result = withUnsafePointer(to: &addr) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard result == 0 else { throw TransportError.system(errno) }
        var uid: uid_t = 0; var gid: gid_t = 0
        guard getpeereid(fd, &uid, &gid) == 0, uid == getuid() else { throw TransportError.disconnected }
        try SocketIO.writeLine(data, fd: fd)
        do { return try JSONDecoder().decode(HookDecision.self, from: SocketIO.readLine(fd, timeout: duration)) }
        catch TransportError.disconnected { return .delegate }
    }
}
