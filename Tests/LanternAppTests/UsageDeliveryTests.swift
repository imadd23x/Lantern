import Foundation
import Testing
import LanternCore
import LanternTransport
@testable import LanternApp

@MainActor
@Test func usageDeliveryDoesNotCreateSessionsOrChangePresentationOrDecideRequests() async throws {
    let directory = URL(fileURLWithPath: "/private/tmp/lantern-usage-delivery-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let suite = "lantern-usage-delivery-" + UUID().uuidString
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let model = AppModel(directory: directory, desktopPreferences: DesktopPreferences(defaults: defaults),
        configurationURLs: [.codex: directory.appendingPathComponent("codex.json"), .claude: directory.appendingPathComponent("claude.json")])
    model.quiet = true; model.start(); model.hideCompanion()
    defer { model.stop() }
    var presentations = 0; var decisions = 0
    model.onPresentationChange = { presentations += 1 }
    model.onApprovalDecision = { _ in decisions += 1 }
    let envelope = ClaudeUsageEnvelope(snapshot: ClaudeUsageSnapshot(fiveHour: UsageWindow(usedPercentage: 45, resetsAt: nil), sevenDay: nil))
    let socketPath = model.socketPath
    let result: HookDecision = try await withCheckedThrowingContinuation { continuation in
        Thread.detachNewThread {
            continuation.resume(with: Result { try HookClient.exchange(envelope, socketPath: socketPath) })
        }
    }
    for _ in 0..<100 {
        if model.claudeUsage.fiveHour != nil { break }
        try await Task.sleep(for: .milliseconds(10))
    }
    #expect(result == .delegate)
    #expect(model.claudeUsage.fiveHour?.value.usedPercentage == 45)
    #expect(model.state.sessions.isEmpty && model.state.approvals.isEmpty)
    #expect(model.companionHidden && !model.expanded && presentations == 0 && decisions == 0)
}
