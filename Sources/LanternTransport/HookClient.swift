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
                                timeout: TimeInterval? = nil, cancelled: (() -> Bool)? = nil) throws -> HookDecision {
        try event.validate()
        return try exchange(JSONEncoder().encode(event), socketPath: socketPath,
                            timeout: timeout ?? (event.kind == .approval ? 115 : 0.3), cancelled: cancelled)
    }

    private static func exchange(_ data: Data, socketPath: String, timeout duration: TimeInterval,
                                 cancelled: (() -> Bool)?) throws -> HookDecision {
        guard duration.isFinite, duration > 0, cancelled?() != true else { return .delegate }
        let deadline = ProcessInfo.processInfo.systemUptime + duration
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw TransportError.system(errno) }
        defer { close(fd) }
        SocketIO.configure(fd, timeout: duration)
        try SocketIO.connectClient(fd, path: socketPath, deadline: deadline, cancelled: cancelled)
        var uid: uid_t = 0; var gid: gid_t = 0
        guard getpeereid(fd, &uid, &gid) == 0, uid == getuid() else { throw TransportError.disconnected }
        if cancelled?() == true { return .delegate }
        try SocketIO.writeLine(data, fd: fd, deadline: deadline, cancelled: cancelled)
        do {
            let reply = try SocketIO.readLine(fd, timeout: max(0, deadline - ProcessInfo.processInfo.systemUptime), cancelled: cancelled)
            let decision = try JSONDecoder().decode(HookDecision.self, from: reply)
            return cancelled?() == true ? .delegate : decision
        }
        catch TransportError.disconnected { return .delegate }
    }
}
