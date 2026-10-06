import Combine

/// Retain the current working registration until its replacement has actually succeeded.
@MainActor
final class ShortcutRegistry: ObservableObject {
    @Published private(set) var errors: [ShortcutAction: String] = [:]
    private var active: [ShortcutAction: (binding: ShortcutBinding, token: Int)] = [:]
    private let register: (ShortcutAction, ShortcutBinding) -> Int?
    private let unregister: (Int) -> Void

    init(register: @escaping (ShortcutAction, ShortcutBinding) -> Int?, unregister: @escaping (Int) -> Void) {
        self.register = register; self.unregister = unregister
    }

    func activeBinding(for action: ShortcutAction) -> ShortcutBinding? { active[action]?.binding }

    @discardableResult
    func apply(_ binding: ShortcutBinding, for action: ShortcutAction) -> Bool {
        guard binding.isSafe else {
            errors[action] = "Use a readable key with Command, Control or Option."
            return false
        }
        if !binding.enabled {
            if let old = active.removeValue(forKey: action) { unregister(old.token) }
            errors.removeValue(forKey: action)
            return true
        }
        if active[action]?.binding == binding { errors.removeValue(forKey: action); return true }
        guard !active.contains(where: { $0.key != action && binding.conflicts(with: $0.value.binding) }) else {
            errors[action] = "Another Lantern shortcut uses this combination."
            return false
        }
        guard let token = register(action, binding) else {
            errors[action] = "macOS could not register this combination. Try another."
            return false
        }
        if let old = active[action] { unregister(old.token) }
        active[action] = (binding, token)
        errors.removeValue(forKey: action)
        return true
    }

    func stop() {
        for entry in active.values { unregister(entry.token) }
        active.removeAll()
        errors.removeAll()
    }
}
