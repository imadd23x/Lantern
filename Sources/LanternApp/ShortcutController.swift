import Combine
import Foundation

@MainActor
final class ShortcutController: ObservableObject {
    let preferences: DesktopPreferences
    let registry: ShortcutRegistry
    private let native: CarbonShortcuts
    private var changes: AnyCancellable?
    private var errorsChanged: AnyCancellable?
    private var availabilityChanged: AnyCancellable?
    private let isAvailable: (ShortcutAction) -> Bool
    private let context: (ShortcutAction) -> String?
    private var stopped = false
    @Published private(set) var inputErrors: [ShortcutAction: String] = [:]
    @Published var recording: ShortcutAction? { didSet { synchronize() } }

    init(preferences: DesktopPreferences, onAction: @escaping (ShortcutAction, TimeInterval) -> Void,
         isAvailable: @escaping (ShortcutAction) -> Bool = { _ in true },
         context: @escaping (ShortcutAction) -> String? = { _ in nil },
         availabilityChanges: ObservableObjectPublisher? = nil) {
        self.preferences = preferences; self.isAvailable = isAvailable; self.context = context
        let native = CarbonShortcuts()
        self.native = native
        registry = ShortcutRegistry(register: native.register, unregister: native.unregister)
        native.onAction = { [weak self] action, token, timestamp in
            guard let self, self.recording == nil,
                  preferences.shortcutsEnabled, preferences.bindings[action]?.enabled == true,
                  isAvailable(action), self.registry.owns(token, for: action, context: context(action)) else { return }
            onAction(action, timestamp)
        }
        changes = preferences.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in self?.synchronize() }
        }
        errorsChanged = registry.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
        native.onRelease = { [weak self] in self?.synchronize() }
        availabilityChanged = availabilityChanges?.sink { [weak self] _ in
            Task { @MainActor [weak self] in self?.synchronize() }
        }
        synchronize()
    }

    func error(for action: ShortcutAction) -> String? { inputErrors[action] ?? registry.errors[action] }

    @discardableResult
    func update(_ binding: ShortcutBinding, for action: ShortcutAction) -> Bool {
        recording = nil
        guard preferences.canSetBinding(binding, for: action) else {
            inputErrors[action] = "Use a modified key that is not assigned to another Lantern action."
            return false
        }
        guard !native.isPressed(action) else {
            inputErrors[action] = "Release the held shortcut before changing it."
            return false
        }
        guard !preferences.shortcutsEnabled || registry.apply(effective(binding, for: action), for: action,
                                                              context: context(action)) else { return false }
        guard preferences.setBinding(binding, for: action) else { return false }
        inputErrors.removeValue(forKey: action)
        return true
    }

    func stop() {
        stopped = true
        changes?.cancel(); errorsChanged?.cancel(); availabilityChanged?.cancel()
        registry.stop(); native.stop()
    }

    private func effective(_ binding: ShortcutBinding, for action: ShortcutAction) -> ShortcutBinding {
        var effective = binding
        effective.enabled = binding.enabled && isAvailable(action)
        return effective
    }

    private func synchronize() {
        guard !stopped else { return }
        guard preferences.shortcutsEnabled, recording == nil else { registry.stop(); return }
        for action in ShortcutAction.allCases {
            guard let binding = preferences.bindings[action] else { continue }
            let desired = effective(binding, for: action)
            if native.isPressed(action) {
                if !desired.enabled || registry.activeContext(for: action) != context(action) {
                    var disabled = binding; disabled.enabled = false
                    registry.apply(disabled, for: action)
                }
                continue
            }
            registry.apply(desired, for: action, context: context(action))
        }
    }
}
