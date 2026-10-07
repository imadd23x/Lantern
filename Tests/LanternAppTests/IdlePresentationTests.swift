import Foundation
import Testing
import LanternCore
import LanternTestSupport
@testable import LanternApp

@MainActor
@Suite(.serialized)
struct IdlePresentationTests {
    @Test func idleDeadlineResetsForInteractionAndManualHideCannotHoverReveal() {
        let suite = "lantern-idle-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = DesktopPreferences(defaults: defaults)
        var time: TimeInterval = 1000
        let model = AppModel(clock: { time }, desktopPreferences: preferences)
        time += 29; model.tick()
        #expect(!model.companionHidden)
        model.isPointerInside = true
        time += 60; model.tick()
        #expect(!model.companionHidden)
        model.isPointerInside = false
        time += 29; model.tick()
        #expect(!model.companionHidden)
        time += 1; model.tick()
        #expect(model.companionHidden && model.automaticallyHidden)
        model.revealOnHover()
        #expect(!model.companionHidden && !model.expanded && !model.allowsKeyboardFocus)
        model.hideCompanion(); model.revealOnHover()
        #expect(model.companionHidden && !model.automaticallyHidden)
        model.showCompanion()
        #expect(!model.expanded)
    }

    @Test func expandedSettingsMenusDragAndPinBlockIdleHide() {
        let suite = "lantern-idle-block-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = DesktopPreferences(defaults: defaults)
        var time: TimeInterval = 1000
        let model = AppModel(clock: { time }, desktopPreferences: preferences)
        model.setExpanded(true); time += 100; model.tick()
        #expect(!model.companionHidden)
        model.setExpanded(false)
        model.isSettingsOpen = true; time += 100; model.tick()
        #expect(!model.companionHidden)
        model.isSettingsOpen = false
        model.isMenuOpen = true; time += 100; model.tick()
        #expect(!model.companionHidden)
        model.isMenuOpen = false
        model.isDragging = true; time += 100; model.tick()
        #expect(!model.companionHidden)
        model.isDragging = false
        model.showConnections = true; time += 100; model.tick()
        #expect(!model.companionHidden)
        model.showConnections = false
        time += 29; model.tick()
        #expect(!model.companionHidden)
        preferences.pinned = true; time += 100; model.tick()
        #expect(!model.companionHidden)
        preferences.pinned = false; model.recordInteraction()
        time += 30; model.tick()
        #expect(model.automaticallyHidden)
    }

    @Test func activityAndApprovalsRevealIdleHiddenWithoutTakingKeyboardFocus() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-idle-live-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var time: TimeInterval = 1000
        let suite = "lantern-idle-activity-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = AppModel(directory: directory, clock: { time }, desktopPreferences: DesktopPreferences(defaults: defaults))
        model.quiet = true; model.start()
        defer { model.stop() }
        time += 31; model.tick()
        #expect(model.automaticallyHidden)
        let activity = AgentEvent(provider: .claude, sessionID: "a", kind: .working, cwd: "/A", summary: "Read")
        _ = try await startHookExchange(activity, socketPath: model.socketPath).value
        for _ in 0..<100 {
            if model.workingCount == 1 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(!model.companionHidden && !model.expanded && !model.allowsKeyboardFocus)
        time += 100; model.tick()
        #expect(!model.companionHidden)
        model.hideCompanion()
        let approval = AgentEvent(provider: .claude, sessionID: "a", kind: .approval, cwd: "/A", summary: "Read")
        let reply = startHookExchange(approval, socketPath: model.socketPath, timeout: 3)
        for _ in 0..<100 {
            if model.state.approvals.count == 1 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(model.companionHidden && !model.expanded)
        model.decide(try #require(model.state.approvals.first).id, .deny)
        #expect(try await reply.value == .deny)
    }

    @Test func disablingAutoHideOrPinningRevealsPassivelyAndApprovalStillReturnsToPill() async throws {
        let suite = "lantern-idle-settings-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = DesktopPreferences(defaults: defaults)
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-idle-approval-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var time: TimeInterval = 1000
        let model = AppModel(directory: directory, clock: { time }, desktopPreferences: preferences)
        model.quiet = true; model.start()
        defer { model.stop() }
        time += 31; model.tick()
        preferences.pinned = true
        try await Task.sleep(for: .milliseconds(10))
        #expect(!model.companionHidden && !model.allowsKeyboardFocus)
        preferences.pinned = false
        try await Task.sleep(for: .milliseconds(10))
        time += 31; model.tick()
        preferences.autoHideEnabled = false
        try await Task.sleep(for: .milliseconds(10))
        #expect(!model.companionHidden && !model.allowsKeyboardFocus)
        preferences.autoHideEnabled = true
        try await Task.sleep(for: .milliseconds(10))
        time += 31; model.tick()
        #expect(model.automaticallyHidden)
        let request = AgentEvent(provider: .claude, sessionID: "approval", kind: .approval, cwd: "/A", summary: "Read")
        let reply = startHookExchange(request, socketPath: model.socketPath, timeout: 3)
        for _ in 0..<100 {
            if model.state.approvals.count == 1 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(!model.companionHidden && model.expanded && !model.allowsKeyboardFocus)
        time += 30; model.tick()
        #expect(model.expanded)
        model.decide(try #require(model.state.approvals.first).id, .deny)
        #expect(try await reply.value == .deny)
        #expect(!model.expanded && !model.allowsKeyboardFocus)
    }
}

@Test func hoverHotspotUsesCurrentCompactFrameAndRequiresPointerEntry() {
    let frame = PanelPlacement.frame(size: PanelPlacement.compact, anchor: CGPoint(x: 5000, y: 5000),
                                     bounds: CGRect(x: -1000, y: 0, width: 1000, height: 800))
    let spot = PanelPlacement.revealHotspot(for: frame)
    #expect(spot.midX == frame.midX && spot.width == frame.width)
    var entry = PointerEntry(inside: true)
    let initiallyInside = entry.entered(isInside: true)
    let leaves = entry.entered(isInside: false)
    let enters = entry.entered(isInside: true)
    let stays = entry.entered(isInside: true)
    #expect(!initiallyInside && !leaves && enters && !stays)
}
