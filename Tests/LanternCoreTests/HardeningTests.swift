import Foundation
import Testing
import Darwin
import LanternTransport
import LanternTestSupport
@testable import LanternCore

@Test func removalKeepsOtherHandlersInTheSameGroup() throws {
    let original = Data(#"{"hooks":{"Stop":[{"matcher":"*","hooks":[{"type":"command","command":"'/tmp/lantern-hook' --provider claude # lantern-managed-v1"},{"type":"command","command":"my-other-hook"}]}]}}"#.utf8)
    let result = try HookConfiguration.preview(original: original, provider: .claude, relayPath: "/tmp/lantern-hook", remove: true)
    let root = try #require(try JSONSerialization.jsonObject(with: result.updated) as? [String: Any])
    let hooks = try #require(root["hooks"] as? [String: Any])
    let groups = try #require(hooks["Stop"] as? [[String: Any]])
    #expect(groups.count == 1)
    let handlers = try #require(groups[0]["hooks"] as? [[String: Any]])
    #expect(handlers.count == 1)
    #expect(handlers[0]["command"] as? String == "my-other-hook")
}

@Test func symlinkConfigurationCannotRedirectWrites() throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-link-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let target = dir.appendingPathComponent("original.json")
    let link = dir.appendingPathComponent("settings.json")
    let bytes = Data("{}".utf8)
    try bytes.write(to: target)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
    let plan = try HookConfiguration.preview(original: bytes, provider: .claude, relayPath: "/tmp/lantern-hook", remove: false)
    #expect(throws: (any Error).self) { try ConfigurationTransaction.apply(plan, to: link) }
    #expect(try Data(contentsOf: target) == bytes)
}

@Test func oversizedAndUnsupportedEventsAreRejected() throws {
    var event = AgentEvent.fixture(session: "session", kind: .working)
    event.version = 2
    #expect(throws: (any Error).self) { try event.validate() }
    #expect(throws: (any Error).self) {
        try HookNormalizer.normalize(Data(repeating: 65, count: 200_001), provider: .codex)
    }
}

@Test func sessionIDsAreScopedByProvider() throws {
    var state = SessionState()
    state.apply(.fixture(session: "same", kind: .working), now: 1)
    state.apply(AgentEvent(provider: .claude, sessionID: "same", kind: .thinking, cwd: "/tmp/other", summary: "Thinking"), now: 2)
    #expect(state.sessions.count == 2)
}

@Test func relayDisconnectInvalidatesItsRequest() async throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-eof-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let server = HookServer(directory: dir)
    let disconnected = AsyncStream<String>.makeStream()
    try server.start(onEvent: { _, _ in }, onDisconnect: { disconnected.continuation.yield($0); disconnected.continuation.finish() })
    defer { server.stop() }
    let result = try await startHookExchange(.fixture(session: "a", kind: .approval), socketPath: server.socketPath, timeout: 0.1).value
    #expect(result == .delegate)
    var iterator = disconnected.stream.makeAsyncIterator()
    #expect(await iterator.next() != nil)
}

@Test func telemetryAcknowledgementDoesNotCancelItsEvent() async throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-telemetry-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let server = HookServer(directory: dir)
    let events = AsyncStream<AgentEvent>.makeStream()
    let disconnects = AsyncStream<String>.makeStream()
    try server.start(onEvent: { event, _ in events.continuation.yield(event) },
                     onDisconnect: { disconnects.continuation.yield($0) })
    defer { server.stop() }
    for index in 0..<20 {
        let result = try await startHookExchange(.fixture(session: "telemetry-\(index)", kind: .working), socketPath: server.socketPath).value
        #expect(result == .delegate)
    }
    server.stop()
    events.continuation.finish(); disconnects.continuation.finish()
    var count = 0
    for await _ in events.stream { count += 1 }
    #expect(count == 20)
    for await _ in disconnects.stream { Issue.record("Telemetry must not trigger approval cancellation") }
}

@Test func eachProviderRegistersOnlyItsDocumentedEvents() throws {
    for provider in AgentProvider.allCases {
        let preview = try HookConfiguration.preview(original: nil, provider: provider, relayPath: "/tmp/hook", remove: false)
        let root = try #require(try JSONSerialization.jsonObject(with: preview.updated) as? [String: Any])
        let hooks = try #require(root["hooks"] as? [String: Any])
        #expect((hooks["Notification"] != nil) == (provider == .claude))
        #expect((hooks["PostToolUseFailure"] != nil) == (provider == .claude))
        #expect((hooks["StopFailure"] != nil) == (provider == .claude))
        #expect((hooks["Interrupt"] != nil) == (provider == .codex))
    }
    let event = try #require(try HookNormalizer.normalize(Data(#"{"hook_event_name":"PostToolUseFailure","session_id":"a"}"#.utf8), provider: .claude))
    #expect(event.kind == .attention)
    #expect(event.summary == "Tool failed")
}

@Test func specialConfigurationFilesAreRejectedWithoutBlocking() throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-fifo-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let target = dir.appendingPathComponent("settings.json")
    #expect(mkfifo(target.path, 0o600) == 0)
    #expect(throws: (any Error).self) { try ConfigurationTransaction.read(target) }
}
