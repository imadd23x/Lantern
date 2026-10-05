import Foundation

public enum AgentProvider: String, Codable, CaseIterable, Sendable {
    case codex, claude
    public var title: String { self == .codex ? "Codex" : "Claude Code" }
}

public enum EventKind: String, Codable, Sendable {
    case idle, thinking, working, approval, attention, finished, failed, ended
}

public struct SessionKey: Hashable, Codable, Sendable {
    public let provider: AgentProvider
    public let id: String
    public init(provider: AgentProvider, id: String) { self.provider = provider; self.id = id }
}

/// Versioned local wire contract. Raw hook JSON never crosses into the UI.
public struct AgentEvent: Codable, Equatable, Sendable {
    public var version: Int = 1
    public let provider: AgentProvider
    public let sessionID: String
    public let kind: EventKind
    public let cwd: String
    public let summary: String
    public let detail: String
    public let reason: String
    public let turnID: String?
    public var key: SessionKey { SessionKey(provider: provider, id: sessionID) }

    public init(provider: AgentProvider, sessionID: String, kind: EventKind, cwd: String,
                summary: String, detail: String = "", reason: String = "", turnID: String? = nil) {
        self.provider = provider; self.sessionID = sessionID; self.kind = kind
        self.cwd = cwd; self.summary = summary; self.detail = detail
        self.reason = reason; self.turnID = turnID
    }

    public func validate() throws {
        guard version == 1, !sessionID.isEmpty, sessionID.utf8.count <= 256,
              cwd.utf8.count <= 8192, summary.utf8.count <= 4096,
              detail.utf8.count <= 200_000, reason.utf8.count <= 16_384 else {
            throw EventError.invalidPayload
        }
    }
}

public enum EventError: Error, LocalizedError {
    case invalidPayload
    public var errorDescription: String? { "The agent sent an invalid or unsupported event." }
}

public enum HookDecision: String, Codable, Sendable {
    case allow, deny, delegate
    public var output: String? {
        switch self {
        case .delegate: nil
        case .allow: #"{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}"#
        case .deny: #"{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"Denied in Lantern"}}}"#
        }
    }
}
