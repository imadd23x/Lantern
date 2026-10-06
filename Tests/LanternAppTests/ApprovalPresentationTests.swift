import Foundation
import Testing
import LanternCore
import LanternTransport
import LanternTestSupport
@testable import LanternApp

// Keep scenarios ordered within this suite; other suites still run concurrently.
// LanternTestSupport moves blocking socket clients off the cooperative executor.
@Suite(.serialized)
struct ApprovalPresentationTests {

    @MainActor
    @Test(arguments: [HookDecision.allow, .deny, .delegate])
    func automaticApprovalReturnsToPillAfterLastDecision(decision: HookDecision) async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-presentation-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true
        model.start()
        defer { model.stop() }
        let event = AgentEvent(provider: .claude, sessionID: "automatic", kind: .approval,
                               cwd: "/Projects/Automatic", summary: "Read", detail: "synthetic proposal")
        let socketPath = model.socketPath
        let relay = startHookExchange(event, socketPath: socketPath, timeout: 3)
        for _ in 0..<100 {
            if !model.state.approvals.isEmpty { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let request = try #require(model.state.approvals.first)
        #expect(model.expanded)
        #expect(!model.allowsKeyboardFocus)
        model.decide(request.id, decision)
        #expect(try await relay.value == decision)
        #expect(model.state.approvals.isEmpty)
        #expect(!model.expanded)
        #expect(!model.allowsKeyboardFocus)
        #expect(model.isListening)
    }

    @MainActor
    @Test func manualCardStaysOpenAfterApproval() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-manual-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start(); model.setExpanded(true)
        defer { model.stop() }
        let event = AgentEvent(provider: .codex, sessionID: "manual", kind: .approval,
                               cwd: "/Projects/Manual", summary: "Read", detail: "synthetic proposal")
        let socketPath = model.socketPath
        let relay = startHookExchange(event, socketPath: socketPath, timeout: 3)
        try await waitForApprovals(model, count: 1)
        model.decide(try #require(model.state.approvals.first).id, .allow)
        #expect(try await relay.value == .allow)
        #expect(model.expanded && model.allowsKeyboardFocus)
    }

    @MainActor
    @Test func automaticQueueStaysOpenUntilEveryRequestIsAnswered() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-queue-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let a = AgentEvent(provider: .claude, sessionID: "a", kind: .approval, cwd: "/Projects/Queue", summary: "Read", detail: "sample A")
        let b = AgentEvent(provider: .codex, sessionID: "b", kind: .approval, cwd: "/Projects/Queue", summary: "Read", detail: "sample B")
        let relayA = startHookExchange(a, socketPath: socketPath, timeout: 3)
        let relayB = startHookExchange(b, socketPath: socketPath, timeout: 3)
        try await waitForApprovals(model, count: 2)
        model.decide(try #require(model.state.approvals.first(where: { $0.event.sessionID == "a" })).id, .deny)
        #expect(try await relayA.value == .deny)
        #expect(model.expanded && model.state.approvals.count == 1)
        model.decide(try #require(model.state.approvals.first).id, .allow)
        #expect(try await relayB.value == .allow)
        #expect(!model.expanded && model.state.approvals.isEmpty)
    }

    @MainActor
    @Test func notificationBeforeApprovalStillRestoresThePill() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-notification-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let attention = AgentEvent(provider: .claude, sessionID: "notification", kind: .attention, cwd: "/Projects/Notification", summary: "Needs permission")
        _ = try await startHookExchange(attention, socketPath: socketPath, timeout: 3).value
        let approval = AgentEvent(provider: .claude, sessionID: "notification", kind: .approval, cwd: "/Projects/Notification", summary: "Read", detail: "sample")
        let relay = startHookExchange(approval, socketPath: socketPath, timeout: 3)
        try await waitForApprovals(model, count: 1)
        model.decide(try #require(model.state.approvals.first).id, .allow)
        #expect(try await relay.value == .allow)
        #expect(!model.expanded)
    }

    @MainActor
    private func waitForApprovals(_ model: AppModel, count: Int) async throws {
        for _ in 0..<250 {
            if model.state.approvals.count == count { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        _ = try #require(model.state.approvals.count == count)
    }

    @MainActor
    @Test(arguments: [false, true])
    func explicitPresentationOverridesAutomaticReturn(openConnections: Bool) async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-override-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let event = AgentEvent(provider: .codex, sessionID: "override", kind: .approval, cwd: "/Projects/Override", summary: "Read", detail: "sample")
        let relay = startHookExchange(event, socketPath: socketPath, timeout: 3)
        try await waitForApprovals(model, count: 1)
        if openConnections { model.showConnections = true } else { model.setExpanded(true) }
        model.decide(try #require(model.state.approvals.first).id, .deny)
        #expect(try await relay.value == .deny)
        #expect(model.expanded && model.allowsKeyboardFocus)
    }

    @MainActor
    @Test func cancelledApprovalRestoresAutomaticPresentation() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-cancel-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let event = AgentEvent(provider: .claude, sessionID: "cancel", kind: .approval, cwd: "/Projects/Cancel", summary: "Read", detail: "sample")
        let relay = startHookExchange(event, socketPath: socketPath, timeout: 0.2)
        try await waitForApprovals(model, count: 1)
        #expect(try await relay.value == .delegate)
        try await waitForApprovals(model, count: 0)
        #expect(!model.expanded && model.isListening)
    }

    @MainActor
    @Test func expiryRestoresThePillWithoutReturningAllow() async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-expiry-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var time: TimeInterval = 1000
        let model = AppModel(directory: directory, clock: { time })
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let event = AgentEvent(provider: .claude, sessionID: "expire", kind: .approval, cwd: "/Projects/Expiry", summary: "Read", detail: "sample")
        let relay = startHookExchange(event, socketPath: socketPath, timeout: 3)
        try await waitForApprovals(model, count: 1)
        time += SessionState.approvalLifetime + 1
        try await waitForApprovals(model, count: 0)
        #expect(try await relay.value == .delegate)
        #expect(!model.expanded && model.isListening)
    }
}
