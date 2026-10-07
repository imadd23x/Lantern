import Foundation
import Testing
@testable import LanternCore

@Test func usageAcceptsDocumentedPercentagesAndNeverInventsMissingWindows() throws {
    let data = Data(#"{"session_id":"private","rate_limits":{"five_hour":{"used_percentage":42.5,"resets_at":5000}}}"#.utf8)
    let snapshot = try ClaudeUsageSnapshot.statusLine(data)
    #expect(snapshot.fiveHour?.usedPercentage == 42.5)
    #expect(snapshot.sevenDay == nil)
    var state = ClaudeUsageState()
    try state.receive(snapshot, now: 1000)
    #expect(state.fiveHour?.status(now: 1100) == .fresh)
    #expect(state.sevenDay == nil)
    #expect(state.fiveHour?.status(now: 1900) == .stale)
    #expect(state.fiveHour?.status(now: 5000) == .resetPassed)
    try state.receive(ClaudeUsageSnapshot(fiveHour: nil, sevenDay: UsageWindow(usedPercentage: 0, resetsAt: nil)), now: 2000)
    #expect(state.fiveHour == nil)
    #expect(state.sevenDay?.value.usedPercentage == 0)
    #expect(state.sevenDay?.status(now: 1900) == .stale)
    try state.receive(ClaudeUsageSnapshot.statusLine(Data("{}".utf8)), now: 3000)
    #expect(state.fiveHour == nil && state.sevenDay == nil)
}

@Test func invalidUsageIsRejectedWithoutOverwritingKnownValues() throws {
    var state = ClaudeUsageState()
    try state.receive(ClaudeUsageSnapshot(fiveHour: UsageWindow(usedPercentage: 30, resetsAt: 5000), sevenDay: nil), now: 1000)
    for value: Double in [-1, 101, .nan, .infinity] {
        #expect(throws: (any Error).self) {
            try state.receive(ClaudeUsageSnapshot(fiveHour: UsageWindow(usedPercentage: value, resetsAt: nil), sevenDay: nil), now: 1100)
        }
    }
    #expect(state.fiveHour?.value.usedPercentage == 30)
    for json in [#"{"rate_limits":true}"#, #"{"rate_limits":{"five_hour":{"used_percentage":true}}}"#,
                 #"{"rate_limits":{"five_hour":{"used_percentage":"40"}}}"#,
                 #"{"rate_limits":{"five_hour":{"used_percentage":40,"resets_at":-1}}}"#] {
        #expect(throws: (any Error).self) { try ClaudeUsageSnapshot.statusLine(Data(json.utf8)) }
    }
    #expect(throws: (any Error).self) {
        try ClaudeUsageEnvelope(version: 2, snapshot: ClaudeUsageSnapshot(fiveHour: nil, sevenDay: nil)).validate()
    }
}
