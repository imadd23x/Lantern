import Foundation

public enum UsageError: Error { case invalid, unsupported }

public struct UsageWindow: Codable, Equatable, Sendable {
    public let usedPercentage: Double
    public let resetsAt: TimeInterval?
    public init(usedPercentage: Double, resetsAt: TimeInterval?) {
        self.usedPercentage = usedPercentage; self.resetsAt = resetsAt
    }
    public func validate() throws {
        guard usedPercentage.isFinite, (0...100).contains(usedPercentage),
              resetsAt.map({ $0.isFinite && $0 > 0 }) ?? true else { throw UsageError.invalid }
    }
}

public struct ClaudeUsageSnapshot: Codable, Equatable, Sendable {
    public let fiveHour: UsageWindow?
    public let sevenDay: UsageWindow?
    public init(fiveHour: UsageWindow?, sevenDay: UsageWindow?) { self.fiveHour = fiveHour; self.sevenDay = sevenDay }
    public func validate() throws { try fiveHour?.validate(); try sevenDay?.validate() }

    /// Decode only the documented quota fields; session, project and prompt data never reach the wire.
    public static func statusLine(_ data: Data) throws -> Self {
        guard data.count <= 200_000 else { throw UsageError.invalid }
        let raw = try JSONDecoder().decode(StatusLine.self, from: data)
        let snapshot = Self(fiveHour: raw.rate_limits?.five_hour?.window, sevenDay: raw.rate_limits?.seven_day?.window)
        try snapshot.validate()
        return snapshot
    }
}

private struct StatusLine: Decodable {
    struct Limits: Decodable { let five_hour: Window?; let seven_day: Window? }
    struct Window: Decodable {
        let used_percentage: Double?
        let resets_at: Double?
        var window: UsageWindow? { used_percentage.map { UsageWindow(usedPercentage: $0, resetsAt: resets_at) } }
    }
    let rate_limits: Limits?
}

public struct ClaudeUsageEnvelope: Codable, Sendable {
    public let type: String
    public let version: Int
    public let snapshot: ClaudeUsageSnapshot
    public init(version: Int = 1, snapshot: ClaudeUsageSnapshot) {
        type = "claude_usage"; self.version = version; self.snapshot = snapshot
    }
    public func validate() throws {
        guard type == "claude_usage", version == 1 else { throw UsageError.unsupported }
        try snapshot.validate()
    }
}

public enum UsageFreshness: Sendable { case fresh, stale, resetPassed }

public struct ReceivedUsageWindow: Equatable, Sendable {
    public let value: UsageWindow
    public let receivedAt: TimeInterval
    public func status(now: TimeInterval) -> UsageFreshness {
        if let reset = value.resetsAt, now >= reset { return .resetPassed }
        return now < receivedAt || now - receivedAt >= 900 ? .stale : .fresh
    }
}

public struct ClaudeUsageState: Equatable, Sendable {
    public private(set) var fiveHour: ReceivedUsageWindow?
    public private(set) var sevenDay: ReceivedUsageWindow?
    public init() {}
    /// Every payload is a complete snapshot. Omitted windows clear their old values.
    public mutating func receive(_ snapshot: ClaudeUsageSnapshot, now: TimeInterval) throws {
        try snapshot.validate()
        guard now.isFinite else { throw UsageError.invalid }
        fiveHour = snapshot.fiveHour.map { ReceivedUsageWindow(value: $0, receivedAt: now) }
        sevenDay = snapshot.sevenDay.map { ReceivedUsageWindow(value: $0, receivedAt: now) }
    }
}
