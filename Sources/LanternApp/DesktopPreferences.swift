import Combine
import Foundation

@MainActor
final class DesktopPreferences: ObservableObject {
    private let defaults: UserDefaults
    @Published var autoHideEnabled: Bool { didSet { defaults.set(autoHideEnabled, forKey: "desktop.autoHide") } }
    @Published var pinned: Bool { didSet { defaults.set(pinned, forKey: "desktop.pinned") } }
    @Published var shortcutsEnabled: Bool { didSet { defaults.set(shortcutsEnabled, forKey: "desktop.shortcutsEnabled") } }
    @Published var usageDisplayEnabled: Bool { didSet { defaults.set(usageDisplayEnabled, forKey: "desktop.usageDisplay") } }
    @Published private(set) var idleDelay: TimeInterval
    @Published private(set) var bindings: [ShortcutAction: ShortcutBinding]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        autoHideEnabled = defaults.object(forKey: "desktop.autoHide") as? Bool ?? true
        pinned = defaults.object(forKey: "desktop.pinned") as? Bool ?? false
        shortcutsEnabled = defaults.object(forKey: "desktop.shortcutsEnabled") as? Bool ?? true
        usageDisplayEnabled = defaults.object(forKey: "desktop.usageDisplay") as? Bool ?? true
        let delay = defaults.double(forKey: "desktop.idleDelay")
        idleDelay = delay.isFinite && (10...300).contains(delay) ? delay : 30
        let stored = defaults.data(forKey: "desktop.bindings")
            .flatMap { $0.count <= 16_000 ? try? JSONDecoder().decode([ShortcutAction: ShortcutBinding].self, from: $0) : nil }
        bindings = stored?.filter { $0.value.isSafe } ?? ShortcutBinding.defaults
        for action in ShortcutAction.allCases where bindings[action] == nil { bindings[action] = ShortcutBinding.defaults[action] }
    }

    @discardableResult
    func setIdleDelay(_ value: TimeInterval) -> Bool {
        guard value.isFinite, (10...300).contains(value) else { return false }
        idleDelay = value; defaults.set(value, forKey: "desktop.idleDelay")
        return true
    }

    @discardableResult
    func setBinding(_ binding: ShortcutBinding, for action: ShortcutAction) -> Bool {
        guard canSetBinding(binding, for: action) else { return false }
        var next = bindings; next[action] = binding
        guard let data = try? JSONEncoder().encode(next) else { return false }
        defaults.set(data, forKey: "desktop.bindings")
        bindings = next
        return true
    }

    func canSetBinding(_ binding: ShortcutBinding, for action: ShortcutAction) -> Bool {
        binding.isSafe && !bindings.contains { $0.key != action && binding.conflicts(with: $0.value) }
    }
}
