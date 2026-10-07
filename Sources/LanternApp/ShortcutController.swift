import Combine

@MainActor
final class ShortcutController: ObservableObject {
    let preferences: DesktopPreferences
    let registry: ShortcutRegistry
    private let native: CarbonShortcuts
    private var changes: AnyCancellable?
    private var errorsChanged: AnyCancellable?
    private var stopped = false
    @Published private(set) var inputErrors: [ShortcutAction: String] = [:]
    @Published var recording: ShortcutAction? { didSet { synchronize() } }

    init(preferences: DesktopPreferences, onAction: @escaping (ShortcutAction) -> Void) {
        self.preferences = preferences
        let native = CarbonShortcuts(onAction: onAction)
        self.native = native
        registry = ShortcutRegistry(register: native.register, unregister: native.unregister)
        changes = preferences.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in self?.synchronize() }
        }
        errorsChanged = registry.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
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
        guard !preferences.shortcutsEnabled || registry.apply(binding, for: action) else { return false }
        guard preferences.setBinding(binding, for: action) else { return false }
        inputErrors.removeValue(forKey: action)
        return true
    }

    func stop() {
        stopped = true
        changes?.cancel(); errorsChanged?.cancel()
        registry.stop(); native.stop()
    }

    private func synchronize() {
        guard !stopped else { return }
        guard preferences.shortcutsEnabled, recording == nil else { registry.stop(); return }
        for action in ShortcutAction.allCases {
            if let binding = preferences.bindings[action] { registry.apply(binding, for: action) }
        }
    }
}
