import Foundation
import Testing
import LanternCore
import LanternTestSupport
@testable import LanternApp

@MainActor
@Suite(.serialized)
struct DesktopCommandTests {
    @Test func providerCommandsCycleOneSharedFilterAndRevealThePanel() {
        let model = AppModel()
        model.hideCompanion()
        model.performShortcut(.nextProvider)
        #expect(model.providerFilter == .codex && !model.companionHidden && model.expanded)
        model.performShortcut(.nextProvider)
        #expect(model.providerFilter == .claude)
        model.performShortcut(.nextProvider)
        #expect(model.providerFilter == nil)
        model.performShortcut(.previousProvider)
        #expect(model.providerFilter == .claude)
        let quiet = model.quiet
        model.performShortcut(.mute)
        #expect(model.quiet != quiet)
    }

    @Test func attentionCommandSelectsAnExistingRequestWithoutDeciding() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-commands-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start()
        defer { model.stop() }
        let a = AgentEvent(provider: .claude, sessionID: "a", kind: .approval, cwd: "/Projects/A", summary: "Read")
        let b = AgentEvent(provider: .codex, sessionID: "b", kind: .approval, cwd: "/Projects/B", summary: "Read")
        let relayA = startHookExchange(a, socketPath: model.socketPath, timeout: 3)
        let relayB = startHookExchange(b, socketPath: model.socketPath, timeout: 3)
        for _ in 0..<100 {
            if model.state.approvals.count == 2 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let first = try #require(model.selectedApproval)
        model.selectedRequestID = first.id
        model.hideCompanion()
        model.performShortcut(.attention)
        #expect(!model.companionHidden && model.expanded && model.allowsKeyboardFocus)
        #expect(model.selectedApproval?.id != first.id && model.state.approvals.count == 2)
        #expect(model.providerFilter == model.selectedApproval?.event.provider)
        for request in model.state.approvals { model.decide(request.id, .deny) }
        #expect(try await relayA.value == .deny)
        #expect(try await relayB.value == .deny)
    }
}
