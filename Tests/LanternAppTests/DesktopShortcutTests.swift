import Foundation
import Testing
@testable import LanternApp

@Test func shortcutsRequireIntentionalModifiersAndReadableKeys() {
    for binding in ShortcutBinding.defaults.values {
        #expect(binding.isSafe)
        #expect(!binding.modifiers.isEmpty)
    }
    #expect(ShortcutAction.allCases.count == 2)
    #expect(ShortcutBinding.defaults[.allowOnce] == ShortcutBinding(keyCode: 36, modifiers: .command, keyName: "Return"))
    #expect(ShortcutBinding.defaults[.hide] == ShortcutBinding(keyCode: 4, modifiers: [.command, .option], keyName: "H"))
    for modifiers in [ShortcutModifiers(), .shift, ShortcutModifiers(rawValue: 255)] {
        #expect(!ShortcutBinding(keyCode: 0, modifiers: modifiers, keyName: "A").isSafe)
    }
    #expect(!ShortcutBinding(keyCode: 65535, modifiers: .standard, keyName: "A").isSafe)
    #expect(!ShortcutBinding(keyCode: 0, modifiers: .standard, keyName: "\n").isSafe)
    #expect(ShortcutBinding(keyCode: 49, modifiers: [.command, .shift], keyName: "Space").isSafe)
}

@MainActor
@Test func shortcutMetadataEditsAndDisablingDoNotNeedNewNativeRegistration() throws {
    var token: Int?
    let registry = ShortcutRegistry(register: { _, _ in
        guard token == nil else { return nil }
        token = 1; return 1
    }, unregister: { _ in token = nil })
    var binding = try #require(ShortcutBinding.defaults[.hide])
    #expect(registry.apply(binding, for: .hide))
    binding.keyName = "New L"
    #expect(registry.apply(binding, for: .hide))
    #expect(registry.activeBinding(for: .hide)?.keyName == "New L" && token != nil)
    binding.enabled = false; binding.keyName = ""
    #expect(registry.apply(binding, for: .hide))
    #expect(registry.activeBinding(for: .hide) == nil && token == nil)
}

@MainActor
@Test func failedShortcutReplacementRetainsTheWorkingRegistration() throws {
    var tokens: Set<Int> = []
    var next = 0
    let registry = ShortcutRegistry(register: { _, binding in
        if binding.keyCode == 99 { return nil }
        next += 1; tokens.insert(next); return next
    }, unregister: { tokens.remove($0) })
    let original = try #require(ShortcutBinding.defaults[.hide])
    #expect(registry.apply(original, for: .hide))
    #expect(tokens.count == 1)
    let unavailable = ShortcutBinding(keyCode: 99, modifiers: .standard, keyName: "F3")
    #expect(!registry.apply(unavailable, for: .hide))
    #expect(registry.activeBinding(for: .hide) == original && tokens.count == 1)
    #expect(registry.errors[.hide] != nil)
    let replacement = ShortcutBinding(keyCode: 1, modifiers: .standard, keyName: "S")
    #expect(registry.apply(replacement, for: .hide))
    #expect(registry.activeBinding(for: .hide) == replacement && tokens.count == 1)
    #expect(registry.errors[.hide] == nil)
    registry.stop()
    #expect(tokens.isEmpty)
}

@MainActor
@Test func desktopSettingsPersistWithoutAcceptingDuplicateBindings() throws {
    let name = "lantern-preferences-" + UUID().uuidString
    let defaults = try #require(UserDefaults(suiteName: name))
    defer { defaults.removePersistentDomain(forName: name) }
    let settings = DesktopPreferences(defaults: defaults)
    settings.autoHideEnabled = false; settings.pinned = true
    #expect(settings.setIdleDelay(60))
    #expect(!settings.setIdleDelay(.nan))
    #expect(!settings.setBinding(try #require(settings.bindings[.allowOnce]), for: .hide))
    let custom = ShortcutBinding(keyCode: 1, modifiers: [.command, .option], keyName: "S")
    #expect(settings.setBinding(custom, for: .hide))
    let restored = DesktopPreferences(defaults: defaults)
    #expect(!restored.autoHideEnabled && restored.pinned && restored.idleDelay == 60)
    #expect(restored.bindings[.hide] == custom)
}
