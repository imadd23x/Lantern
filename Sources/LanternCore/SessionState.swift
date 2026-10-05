import Foundation

public struct AgentSession: Identifiable, Sendable {
    public let id: SessionKey
    public var cwd: String
    public var phase: EventKind
    public var summary: String
    public var updatedAt: TimeInterval
    public var project: String {
        cwd.isEmpty ? id.provider.title : URL(fileURLWithPath: cwd).lastPathComponent
    }
}

public struct PendingApproval: Identifiable, Sendable {
    public let id: String
    public let event: AgentEvent
    public let expiresAt: TimeInterval
}

/// Pure state transitions. Socket ownership and rendering stay outside this module.
public struct SessionState: Sendable {
    public private(set) var sessions: [SessionKey: AgentSession] = [:]
    public private(set) var approvals: [PendingApproval] = []
    public static let approvalLifetime: TimeInterval = 110
    public init() {}

    @discardableResult
    public mutating func apply(_ event: AgentEvent, requestID: String? = nil, now: TimeInterval) -> [String] {
        var removed: [String] = []
        if event.kind == .ended || event.kind == .finished || event.kind == .failed {
            removed = approvals.filter { $0.event.key == event.key }.map(\.id)
            approvals.removeAll { $0.event.key == event.key }
        }
        if event.kind == .approval, let requestID,
           !approvals.contains(where: { $0.id == requestID }) {
            approvals.append(PendingApproval(id: requestID, event: event, expiresAt: now + Self.approvalLifetime))
        }
        let phase: EventKind = approvals.contains { $0.event.key == event.key } ? .approval : event.kind
        sessions[event.key] = AgentSession(id: event.key, cwd: event.cwd, phase: phase,
                                           summary: event.summary, updatedAt: now)
        prune(now: now)
        return removed
    }

    public mutating func resolve(_ id: String, now: TimeInterval) -> PendingApproval? {
        guard let index = approvals.firstIndex(where: { $0.id == id }) else { return nil }
        let request = approvals.remove(at: index)
        if let session = sessions[request.event.key] {
            sessions[request.event.key]?.phase = approvals.contains { $0.event.key == session.id } ? .approval : .attention
            sessions[request.event.key]?.summary = "Waiting for the agent"
        }
        return now < request.expiresAt ? request : nil
    }

    public mutating func expire(now: TimeInterval) -> [String] {
        let ids = approvals.filter { now >= $0.expiresAt }.map(\.id)
        for id in ids { _ = resolve(id, now: now) }
        return ids
    }

    private mutating func prune(now: TimeInterval) {
        let protected = Set(approvals.map { $0.event.key })
        sessions = sessions.filter { protected.contains($0.key) || now - $0.value.updatedAt < 3600 }
        if sessions.count > 100 {
            for entry in sessions.values.sorted(by: { $0.updatedAt < $1.updatedAt }) where !protected.contains(entry.id) {
                if sessions.count <= 100 { break }
                sessions.removeValue(forKey: entry.id)
            }
        }
    }
}
