import Foundation
import Testing
@testable import LanternCore

@Test func usageWrapperIsIdempotentPreservesCommandsAndRestoresAbsentVersusNull() throws {
    let path = "/Applications/Imad's Lantern.app/Contents/MacOS/lantern-hook"
    for original in [Data(#"{"theme":"dark"}"#.utf8), Data(#"{"statusLine":null,"theme":"dark"}"#.utf8),
                     Data(#"{"statusLine":{"type":"command","command":"printf '%s' \"$CUSTOM\"; cat","padding":2},"theme":"dark"}"#.utf8)] {
        let preview = try StatusLineConfiguration.preview(original: original, relayPath: path, remove: false)
        let repeatPreview = try StatusLineConfiguration.preview(original: preview.updated, relayPath: path, remove: false)
        #expect(preview.updated == repeatPreview.updated)
        #expect(try StatusLineConfiguration.isInstalled(original: preview.updated))
        let restored = try StatusLineConfiguration.preview(original: preview.updated, relayPath: path, remove: true)
        let a = try JSONSerialization.jsonObject(with: original) as! NSDictionary
        let b = try JSONSerialization.jsonObject(with: restored.updated) as! NSDictionary
        #expect(a.isEqual(b))
        let relocated = try StatusLineConfiguration.preview(original: preview.updated, relayPath: "/New/Lantern.app/Contents/MacOS/lantern-hook", remove: false)
        let restoredRelocated = try StatusLineConfiguration.preview(original: relocated.updated, relayPath: path, remove: true)
        #expect(a.isEqual(try JSONSerialization.jsonObject(with: restoredRelocated.updated)))
    }
}

@Test func externalReplacementAndMalformedSnapshotsCannotBeRestoredOver() throws {
    let original = Data(#"{"statusLine":{"type":"command","command":"echo user"},"hooks":{}}"#.utf8)
    let removal = try StatusLineConfiguration.preview(original: original, relayPath: "/A/lantern-hook", remove: true)
    #expect(removal.updated == original)
    #expect(try !StatusLineConfiguration.isInstalled(original: original))
    for json in [#"{"statusLine":true}"#, #"{"statusLine":{"type":"unknown","command":"cat"}}"#,
                 #"{"statusLine":{"type":"command","command":23}}"#] {
        #expect(throws: (any Error).self) {
            try StatusLineConfiguration.preview(original: Data(json.utf8), relayPath: "/A/lantern-hook", remove: false)
        }
    }
    #expect(throws: (any Error).self) { try StatusLineConfiguration.previousCommand(snapshot: "not base64") }
    #expect(throws: (any Error).self) { try StatusLineConfiguration.previousCommand(snapshot: String(repeating: "A", count: 64_001)) }
}

@Test func usageConfigurationUsesExistingExactBackupAndStalePreviewGuard() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("lantern-usage-config-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("settings.json")
    let original = Data(#"{"statusLine":{"type":"command","command":"cat"},"unknown":{"keep":true}}"#.utf8)
    try original.write(to: url)
    let preview = try StatusLineConfiguration.preview(original: original, relayPath: "/A/lantern-hook", remove: false)
    let backup = try #require(try ConfigurationTransaction.apply(preview, to: url))
    #expect(try Data(contentsOf: backup) == original)
    #expect(throws: ConfigurationError.changed) { try ConfigurationTransaction.apply(preview, to: url) }
}
