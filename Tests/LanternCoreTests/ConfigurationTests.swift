import Foundation
import Testing
@testable import LanternCore

@Test func hookMergePreservesSettingsAndNeighborHandlers() throws {
    let original = Data(#"{"theme":"dark","hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"custom-lint"}]}]}}"#.utf8)
    let plan = try HookConfiguration.preview(original: original, provider: .claude, relayPath: "/tmp/Lantern.app/Contents/MacOS/lantern-hook", remove: false)
    let root = try #require(JSONSerialization.jsonObject(with: plan.updated) as? [String: Any])
    #expect(root["theme"] as? String == "dark")
    let hooks = try #require(root["hooks"] as? [String: Any])
    let groups = try #require(hooks["PreToolUse"] as? [[String: Any]])
    #expect(groups.count == 2)
    #expect((groups[0]["hooks"] as? [[String: Any]])?[0]["command"] as? String == "custom-lint")
    let removed = try HookConfiguration.preview(original: plan.updated, provider: .claude, relayPath: "/tmp/Lantern.app/Contents/MacOS/lantern-hook", remove: true)
    #expect(try JSONSerialization.jsonObject(with: removed.updated) as? NSDictionary == JSONSerialization.jsonObject(with: original) as? NSDictionary)
}

@Test func malformedConfigurationIsNeverReplaced() throws {
    for raw in ["bad json", "[]", #"{"hooks":[]}"#, #"{"hooks":{"PreToolUse":{}}}"#, #"{"hooks":{"Stop":[{"hooks":"bad"}]}}"#] {
        #expect(throws: (any Error).self) {
            try HookConfiguration.preview(original: Data(raw.utf8), provider: .codex, relayPath: "/tmp/hook", remove: false)
        }
    }
}

@Test func installingTwiceIsIdempotentAndQuotesShellCharacters() throws {
    let path = "/tmp/Imad's $project/Lantern.app/Contents/MacOS/lantern-hook"
    let first = try HookConfiguration.preview(original: nil, provider: .codex, relayPath: path, remove: false)
    let second = try HookConfiguration.preview(original: first.updated, provider: .codex, relayPath: path, remove: false)
    #expect(first.updated == second.updated)
    #expect(ShellArgument.quote("a'b") == "'a'\\''b'")
}

@Test func transactionRejectsStalePreviewAndBacksUpExactly() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let url = dir.appendingPathComponent("settings.json")
    let original = Data(#"{"unrelated":true}"#.utf8)
    try original.write(to: url)
    let preview = try HookConfiguration.preview(original: original, provider: .claude, relayPath: "/tmp/hook", remove: false)
    try Data(#"{"new":true}"#.utf8).write(to: url)
    #expect(throws: (any Error).self) { try ConfigurationTransaction.apply(preview, to: url) }
    #expect(String(decoding: try Data(contentsOf: url), as: UTF8.self) == #"{"new":true}"#)
    try original.write(to: url)
    let backup = try #require(try ConfigurationTransaction.apply(preview, to: url))
    #expect(try Data(contentsOf: backup) == original)
    #expect(try Data(contentsOf: url) == preview.updated)
}
