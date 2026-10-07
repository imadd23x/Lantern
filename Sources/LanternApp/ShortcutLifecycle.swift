/// Tracks physical intent separately from whether a shortcut is currently actionable.
struct ShortcutLifecycle {
    private var held: Set<ShortcutAction> = []
    private var registrations: [Int: (action: ShortcutAction, deferred: Bool)] = [:]

    mutating func registered(_ token: Int, for action: ShortcutAction, alreadyPressed: Bool = false) {
        registrations[token] = (action, false)
        if alreadyPressed { held.insert(action) }
    }
    func isPressed(_ action: ShortcutAction) -> Bool { held.contains(action) }
    mutating func press(_ action: ShortcutAction) -> Bool { held.insert(action).inserted }

    /// False means retain the native reference until release, so no release event is lost.
    mutating func remove(_ token: Int) -> Bool {
        guard let registration = registrations[token] else { return false }
        if held.contains(registration.action) {
            registrations[token]?.deferred = true
            return false
        }
        registrations.removeValue(forKey: token)
        return true
    }

    mutating func release(_ action: ShortcutAction) -> [Int] {
        held.remove(action)
        let tokens = registrations.filter { $0.value.action == action && $0.value.deferred }.map(\.key)
        for token in tokens { registrations.removeValue(forKey: token) }
        return tokens
    }
    mutating func stop() -> [Int] {
        let tokens = Array(registrations.keys)
        registrations.removeAll(); held.removeAll()
        return tokens
    }
}
