import Foundation
import Testing
@testable import LanternCore

@Test func sessionsFromSameProviderRemainIndependent() throws {
    var state = SessionState()
    state.apply(.fixture(session: "a", kind: .working), now: 10)
    state.apply(.fixture(session: "b", kind: .thinking), now: 11)
    #expect(state.sessions.count == 2)
    #expect(state.sessions[SessionKey(provider: .codex, id: "a")]?.phase == .working)
}

@Test func concurrentApprovalsQueueAndResolveIndividually() throws {
    var state = SessionState()
    state.apply(.fixture(session: "a", kind: .approval), requestID: "r1", now: 10)
    state.apply(.fixture(session: "b", kind: .approval), requestID: "r2", now: 11)
    #expect(state.approvals.map(\.id) == ["r1", "r2"])
    #expect(state.resolve("r2", now: 12) != nil)
    #expect(state.approvals.map(\.id) == ["r1"])
    #expect(state.resolve("r2", now: 13) == nil)
}

@Test func expiredAndEndedRequestsCannotBeApproved() throws {
    var state = SessionState()
    state.apply(.fixture(session: "a", kind: .approval), requestID: "expired", now: 1)
    #expect(state.expire(now: 200) == ["expired"])
    #expect(state.resolve("expired", now: 200) == nil)
    state.apply(.fixture(session: "b", kind: .approval), requestID: "ended", now: 201)
    #expect(state.apply(.fixture(session: "b", kind: .finished), now: 202) == ["ended"])
    #expect(state.resolve("ended", now: 202) == nil)
}

@Test func malformedOrUnknownHooksHaveNoDecision() throws {
    #expect(throws: (any Error).self) {
        try HookNormalizer.normalize(Data("{}".utf8), provider: .codex)
    }
    let raw = Data(#"{"session_id":"a","hook_event_name":"SomethingNew"}"#.utf8)
    #expect(try HookNormalizer.normalize(raw, provider: .codex) == nil)
    #expect(HookDecision.delegate.output == nil)
    #expect(HookDecision.allow.output?.contains("allow") == true)
    #expect(HookDecision.deny.output?.contains("deny") == true)
}

@Test func permissionsKeepTheWholeProposedAction() throws {
    let raw = Data(#"{"session_id":"a","hook_event_name":"PermissionRequest","cwd":"/tmp/project","tool_name":"Bash","tool_input":{"command":"echo hello","description":"Test command"}}"#.utf8)
    let event = try #require(try HookNormalizer.normalize(raw, provider: .claude))
    #expect(event.kind == .approval)
    #expect(event.detail.contains("echo hello"))
    #expect(event.reason == "Test command")
    #expect(event.provider == .claude)
}

extension AgentEvent {
    static func fixture(session: String, kind: EventKind) -> AgentEvent {
        AgentEvent(provider: .codex, sessionID: session, kind: kind, cwd: "/tmp/project", summary: "Example", detail: "echo hello")
    }
}
