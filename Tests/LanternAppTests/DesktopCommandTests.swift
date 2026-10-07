import Foundation
import Testing
import LanternCore
import LanternTestSupport
@testable import LanternApp

@MainActor
@Suite(.serialized)
struct DesktopCommandTests {
    @Test func visibilityShortcutTogglesAndAlwaysReopensCompact() {
        let model = AppModel()
        model.showCompanion(expanded: true)
        model.performShortcut(.visibility)
        #expect(model.companionHidden && !model.expanded)
        model.performShortcut(.visibility)
        #expect(!model.companionHidden && !model.expanded)
    }

    @Test func allowShortcutRequiresTheDisplayedRequestAndPreservesQueueAndPassiveFocus() async throws {
        let fixture = Fixture()
        defer { fixture.stop() }
        let model = fixture.model
        model.start()
        let a = startHookExchange(fixture.event("a"), socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 1)
        let first = try #require(model.selectedApproval)
        let b = startHookExchange(fixture.event("b"), socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 2)
        #expect(!model.allowsGlobalApproval)
        model.setDisplayedApproval(first.id, visible: true)
        #expect(!model.allowsGlobalApproval) // Still opening; onAppear alone is insufficient.
        model.approvalPresentationReady = true
        #expect(model.allowsGlobalApproval && !model.allowsKeyboardFocus)
        model.performShortcut(.allowOnce)
        #expect(try await a.value == .allow)
        #expect(model.state.approvals.count == 1 && model.expanded)
        model.performShortcut(.allowOnce)
        #expect(model.state.approvals.count == 1) // Old rendered ID cannot approve the next card.
        let second = try #require(model.selectedApproval)
        model.setDisplayedApproval(second.id, visible: true)
        model.setDisplayedApproval(first.id, visible: false) // Late old-view disappearance.
        #expect(model.allowsGlobalApproval)
        model.performShortcut(.allowOnce)
        #expect(try await b.value == .allow)
        #expect(!model.expanded && !model.allowsKeyboardFocus)
    }

    @Test func approvalShortcutRejectsHiddenSettingsAndExpiredRequests() async throws {
        let fixture = Fixture()
        defer { fixture.stop() }
        let model = fixture.model
        model.start()
        let relay = startHookExchange(fixture.event("guard"), socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 1)
        model.setDisplayedApproval(try #require(model.selectedApproval).id, visible: true)
        model.approvalPresentationReady = true
        for blocked in 0..<4 {
            if blocked == 0 { model.isSettingsOpen = true }
            if blocked == 1 { model.showConnections = true }
            if blocked == 2 { model.isSettingsMenuOpen = true }
            if blocked == 3 { model.hideCompanion() }
            model.performShortcut(.allowOnce)
            #expect(model.state.approvals.count == 1)
            model.isSettingsOpen = false; model.showConnections = false; model.isSettingsMenuOpen = false
        }
        model.showCompanion(expanded: true)
        fixture.time += SessionState.approvalLifetime + 1
        model.performShortcut(.allowOnce)
        #expect(!model.allowsGlobalApproval && model.state.approvals.count == 1)
        model.tick()
        #expect(try await relay.value == .delegate)
    }

    @Test func missingProposalNeverEnablesGlobalAllow() async throws {
        let fixture = Fixture()
        defer { fixture.stop() }
        let model = fixture.model
        model.start()
        let event = AgentEvent(provider: .claude, sessionID: "empty", kind: .approval, cwd: "/Projects/Fixture", summary: "Read")
        let relay = startHookExchange(event, socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 1)
        let request = try #require(model.selectedApproval)
        model.setDisplayedApproval(request.id, visible: true)
        model.approvalPresentationReady = true
        model.performShortcut(.allowOnce)
        #expect(!model.allowsGlobalApproval && model.state.approvals.count == 1)
        model.decide(request.id, .deny)
        #expect(try await relay.value == .deny)
    }

    @Test func preciseExpiryRemovesAnActionableRequestBeforeTheNextPollingTick() async throws {
        let fixture = Fixture()
        defer { fixture.stop() }
        let model = fixture.model
        model.start()
        let relay = startHookExchange(fixture.event("deadline"), socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 1)
        fixture.setTime(to: try #require(model.selectedApproval).expiresAt - 0.10)
        model.tick() // Rebase the precise deadline after the test clock advances.
        try await Task.sleep(for: .milliseconds(250))
        #expect(model.state.approvals.isEmpty)
        if let pending = model.selectedApproval { model.decide(pending.id, .deny) }
        let decision = try await relay.value
        #expect(decision == .delegate)
    }

    @Test(arguments: [false, true])
    func disabledApprovalShortcutRejectsLateCallbacks(disableBinding: Bool) async throws {
        let fixture = Fixture()
        defer { fixture.stop() }
        let model = fixture.model
        model.start()
        let relay = startHookExchange(fixture.event("disabled"), socketPath: model.socketPath, timeout: 5)
        try await wait(model, count: 1)
        let request = try #require(model.selectedApproval)
        model.setDisplayedApproval(request.id, visible: true)
        model.approvalPresentationReady = true
        if disableBinding {
            var binding = try #require(model.desktopPreferences.bindings[.allowOnce])
            binding.enabled = false
            #expect(model.desktopPreferences.setBinding(binding, for: .allowOnce))
        } else { model.desktopPreferences.shortcutsEnabled = false }
        model.performShortcut(.allowOnce)
        #expect(model.state.approvals.count == 1 && !model.allowsGlobalApproval)
        model.decide(request.id, .deny)
        #expect(try await relay.value == .deny)
    }

    private func wait(_ model: AppModel, count: Int) async throws {
        for _ in 0..<100 {
            if model.state.approvals.count == count { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(model.state.approvals.count == count)
    }

    @MainActor
    private final class Fixture {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-allow-key-" + UUID().uuidString)
        let suite = "lantern-allow-key-" + UUID().uuidString
        var time: TimeInterval = 1000
        private let started = ProcessInfo.processInfo.systemUptime
        lazy var defaults = UserDefaults(suiteName: suite)!
        lazy var model: AppModel = {
            let model = AppModel(directory: directory, clock: { [unowned self] in self.time + ProcessInfo.processInfo.systemUptime - self.started },
                desktopPreferences: DesktopPreferences(defaults: defaults),
                configurationURLs: [.codex: directory.appendingPathComponent("codex.json"), .claude: directory.appendingPathComponent("claude.json")])
            model.quiet = true
            return model
        }()
        func setTime(to value: TimeInterval) {
            time = value - (ProcessInfo.processInfo.systemUptime - started)
        }
        func event(_ id: String) -> AgentEvent {
            AgentEvent(provider: .claude, sessionID: id, kind: .approval, cwd: "/Projects/Fixture", summary: "Read", detail: "{\"file\":\"fixture.txt\"}")
        }
        func stop() {
            model.stop(); defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: directory)
        }
    }
}
