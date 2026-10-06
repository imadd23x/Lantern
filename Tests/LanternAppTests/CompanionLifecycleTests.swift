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
    #expect(model.visibilityMenuTitle == "Hide Lantern")
    model.showConnections = true
    model.toggleCompanionVisibility()
    #expect(model.companionHidden && !model.expanded && model.isListening)
    #expect(!model.showConnections)
    #expect(model.visibilityMenuTitle == "Show Lantern")

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
    model.toggleCompanionVisibility()
    #expect(!model.companionHidden && !model.expanded)
    #expect(model.visibilityMenuTitle == "Hide Lantern")
    #expect(model.state.approvals.first?.id == request.id)
    model.decide(request.id, .deny)
    #expect(try await relay.value == .deny)
    #expect(model.state.approvals.isEmpty)
    model.stop()
    #expect(!model.isListening)
    #expect(!FileManager.default.fileExists(atPath: socketPath))
}

@MainActor
@Test func connectionsCanExplicitlyOpenAfterCompactShow() {
    let model = AppModel(directory: URL(fileURLWithPath: "/private/tmp/lantern-show-" + UUID().uuidString))
    model.setExpanded(true)
    model.hideCompanion()
    model.showCompanion()
    #expect(!model.companionHidden && !model.expanded && !model.showConnections)
    model.hideCompanion()
    model.showConnections = true
    model.showCompanion(expanded: true)
    #expect(!model.companionHidden && model.expanded && model.showConnections)
    #expect(model.allowsKeyboardFocus)
}
