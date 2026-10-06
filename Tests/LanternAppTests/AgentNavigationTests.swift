import Foundation
import Testing
import LanternCore
import LanternTransport
import LanternTestSupport
@testable import LanternApp

@Test func claudeWorktreeNavigationCannotOpenAWorkspace() throws {
    var state = SessionState()
    let event = AgentEvent(provider: .claude, sessionID: "live-claude", kind: .approval,
                           cwd: "/Projects/Root/a-different-worktree", summary: "Bash")
    state.apply(event, requestID: "sample", now: 1)
    let session = try #require(state.sessions[event.key])
    #expect(AgentDestination.destination(for: session) == .existingVSCode)
}

@Test func codexNavigationStillEscapesChatIdentity() throws {
    let session = try navigationSession(provider: .codex, id: "thread one?#fragment", kind: .working)
    guard case .link(let url) = AgentDestination.destination(for: session) else {
        Issue.record("Codex lost its chat link"); return
    }
    #expect(url.scheme == "codex" && url.host == "threads")
    #expect(url.query == nil && url.fragment == nil)
    #expect(url.path == "/thread one?#fragment")
}

@MainActor
@Test func endedClaudeCannotCreateAReplacementChat() throws {
    let navigator = AgentNavigator(openURL: { _ in Issue.record("Unexpected URL opening"); return true },
                                   focusExistingCode: { Issue.record("Unexpected ended-session activation"); return true })
    #expect(navigator.open(try navigationSession(provider: .claude, id: "ended", kind: .ended)) != nil)
}

@MainActor
@Suite(.serialized)
struct AgentHandoffTests {
    @Test(arguments: [false, true])
    func handoffRequiresSuccessfulNavigationAndResolvesOnlyItsRequest(navigationSucceeds: Bool) async throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-navigation-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let navigator = AgentNavigator(openURL: { _ in Issue.record("Claude navigation must not open URLs"); return false },
                                       focusExistingCode: { navigationSucceeds })
        let model = AppModel(directory: directory, navigator: navigator)
        model.quiet = true; model.start()
        defer { model.stop() }
        let socketPath = model.socketPath
        let selected = AgentEvent(provider: .claude, sessionID: "selected", kind: .approval,
                                  cwd: "/Projects/ChangedWorktree", summary: "Read", detail: "sample only")
        let neighbor = AgentEvent(provider: .codex, sessionID: "neighbor", kind: .approval,
                                  cwd: "/Projects/Neighbor", summary: "Read", detail: "sample only")
        let selectedRelay = startHookExchange(selected, socketPath: socketPath, timeout: 3)
        let neighborRelay = startHookExchange(neighbor, socketPath: socketPath, timeout: 3)
        for _ in 0..<100 {
            if model.state.approvals.count == 2 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let request = try #require(model.state.approvals.first(where: { $0.event.key == selected.key }))
        let neighborRequest = try #require(model.state.approvals.first(where: { $0.event.key == neighbor.key }))
        let session = try #require(model.state.sessions[selected.key])
        // The row is navigation only; it must not release either permission hook.
        #expect(model.openAgent(session) == navigationSucceeds)
        #expect(model.state.approvals.count == 2)
        model.answerInAgent(request.id)
        if navigationSucceeds {
            #expect(try await selectedRelay.value == .delegate)
            #expect(model.state.approvals.map(\.id) == [neighborRequest.id])
        } else {
            #expect(model.state.approvals.count == 2)
            #expect(model.errorMessage != nil)
            model.decide(request.id, .deny)
            #expect(try await selectedRelay.value == .deny)
        }
        model.decide(neighborRequest.id, .deny)
        #expect(try await neighborRelay.value == .deny)
    }
}

private func navigationSession(provider: AgentProvider, id: String, kind: EventKind) throws -> AgentSession {
    var state = SessionState()
    let event = AgentEvent(provider: provider, sessionID: id, kind: kind, cwd: "/Projects/Worktree", summary: "Sample")
    state.apply(event, now: 1)
    return try #require(state.sessions[event.key])
}
