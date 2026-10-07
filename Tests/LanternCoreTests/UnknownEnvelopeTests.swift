import Foundation
import Darwin
import Testing
import LanternCore
@testable import LanternTransport

@Test func unknownTypedMessagesCannotFallBackToAnApprovalEvent() async throws {
    let directory = URL(fileURLWithPath: "/private/tmp/lantern-unknown-envelope-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let events = AsyncStream<AgentEvent>.makeStream()
    let disconnects = AsyncStream<String>.makeStream()
    let server = HookServer(directory: directory)
    try server.start(onEvent: { event, id in
        events.continuation.yield(event); server.respond(to: id, with: .allow)
    }, onDisconnect: { disconnects.continuation.yield($0) })
    defer { server.stop() }
    let event = AgentEvent(provider: .claude, sessionID: "fixture", kind: .approval, cwd: "/Fixture", summary: "Read")
    var root = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any])
    for discriminator: Any in ["claude_usage", "unknown", true, NSNull()] {
        root["type"] = discriminator
        let result = try await rawTypedExchange(JSONSerialization.data(withJSONObject: root), path: server.socketPath)
        #expect(result == .delegate)
    }
    for json in [#"{"type":"claude_usage","version":2,"snapshot":{}}"#,
                 #"{"type":"claude_usage","version":1,"snapshot":{"fiveHour":{"usedPercentage":101}}}"#] {
        #expect(try await rawTypedExchange(Data(json.utf8), path: server.socketPath) == .delegate)
    }
    server.stop(); events.continuation.finish(); disconnects.continuation.finish()
    for await _ in events.stream { Issue.record("Unknown envelopes must not reach the activity/approval callback") }
    for await _ in disconnects.stream { Issue.record("Unknown envelopes must not cancel approval requests") }
}

private func rawTypedExchange(_ data: Data, path: String) async throws -> HookDecision {
    try await withCheckedThrowingContinuation { continuation in
        Thread.detachNewThread {
            continuation.resume(with: Result {
                let fd = socket(AF_UNIX, SOCK_STREAM, 0)
                guard fd >= 0 else { throw TransportError.system(errno) }
                defer { close(fd) }
                SocketIO.configure(fd, timeout: 1)
                var address = try SocketIO.address(path)
                let connected = withUnsafePointer(to: &address) { pointer in
                    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size)) }
                }
                guard connected == 0 else { throw TransportError.system(errno) }
                try SocketIO.writeLine(data, fd: fd)
                return try JSONDecoder().decode(HookDecision.self, from: SocketIO.readLine(fd, timeout: 1))
            })
        }
    }
}
