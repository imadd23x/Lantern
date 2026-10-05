import Foundation
import Testing
import LanternCore
import LanternTransport
@testable import LanternApp

/// Hidden UI must keep accepting activity and proposals without exposing the card or deciding for the user.
@MainActor
@Test func hidingKeepsTheListenerAndExplicitDecisionFlow() async throws {
    let directory = URL(fileURLWithPath: "/private/tmp/lantern-hidden-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let model = AppModel(directory: directory)
    model.quiet = true
    model.start()
    defer { model.stop() }
    #expect(model.isListening)
    model.showConnections = true
    model.hideCompanion()
    #expect(model.companionHidden && !model.expanded && model.isListening)
    #expect(!model.showConnections)

    let event = AgentEvent(provider: .claude, sessionID: "hidden-request", kind: .approval,
                           cwd: "/Projects/Hidden", summary: "Read", detail: "synthetic proposal")
    let socketPath = model.socketPath
    let relay = Task.detached { try HookClient.exchange(event, socketPath: socketPath, timeout: 3) }
    for _ in 0..<100 {
        if !model.state.approvals.isEmpty { break }
        try await Task.sleep(for: .milliseconds(10))
    }
    let request = try #require(model.state.approvals.first)
    #expect(model.companionHidden && !model.expanded && model.isListening)
    #expect(request.event == event)
    model.showCompanion()
    #expect(!model.companionHidden && model.expanded)
    model.decide(request.id, .deny)
    #expect(try await relay.value == .deny)
    #expect(model.state.approvals.isEmpty)
    model.stop()
    #expect(!model.isListening)
    #expect(!FileManager.default.fileExists(atPath: socketPath))
}
