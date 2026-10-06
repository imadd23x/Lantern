import Foundation
import Testing
import LanternTransport
import LanternTestSupport
@testable import LanternCore

@Test func realSocketReturnsOnlyTheChosenRequestsDecision() async throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-tests-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let server = HookServer(directory: dir)
    try server.start(onEvent: { event, id in
        server.respond(to: id, with: event.sessionID == "a" ? .allow : .deny)
    }, onDisconnect: { _ in })
    defer { server.stop() }
    async let first = startHookExchange(.fixture(session: "a", kind: .approval), socketPath: server.socketPath).value
    async let second = startHookExchange(.fixture(session: "b", kind: .approval), socketPath: server.socketPath).value
    #expect(try await first == .allow)
    #expect(try await second == .deny)
}

@Test func occupiedSocketIsNeverUnlinked() async throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-tests-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let first = HookServer(directory: dir)
    try first.start(onEvent: { _, id in first.respond(to: id, with: .delegate) }, onDisconnect: { _ in })
    defer { first.stop() }
    let second = HookServer(directory: dir)
    #expect(throws: (any Error).self) { try second.start(onEvent: { _, _ in }, onDisconnect: { _ in }) }
    #expect(try await startHookExchange(.fixture(session: "a", kind: .idle), socketPath: first.socketPath).value == .delegate)
}

@Test func stoppingServerDelegatesPendingRequest() async throws {
    let dir = URL(fileURLWithPath: "/tmp/lantern-tests-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let server = HookServer(directory: dir)
    try server.start(onEvent: { _, _ in server.stop() }, onDisconnect: { _ in })
    #expect(try await startHookExchange(.fixture(session: "a", kind: .approval), socketPath: server.socketPath).value == .delegate)
}
