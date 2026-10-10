/// Tracks physical intent separately from whether a shortcut is currently actionable.
struct ShortcutLifecycle {
    private var held: [ShortcutAction: Int] = [:]
    private var registrations: [Int: (action: ShortcutAction, deferred: Bool)] = [:]

    mutating func registered(_ token: Int, for action: ShortcutAction, alreadyPressed: Bool = false) {
        registrations[token] = (action, false)
        if alreadyPressed { held[action] = token }
    }
    func isPressed(_ action: ShortcutAction) -> Bool { held[action] != nil }
    var heldTokens: [Int] { Array(held.values) }

    mutating func press(_ token: Int) -> ShortcutAction? {
        guard let entry = registrations[token], !entry.deferred, held[entry.action] == nil else { return nil }
        held[entry.action] = token
        return entry.action
    }

    /// False means retain the native reference until release, so no release event is lost.
    mutating func remove(_ token: Int) -> Bool {
        guard let registration = registrations[token] else { return false }
        if held[registration.action] == token {
            registrations[token]?.deferred = true
            return false
        }
        registrations.removeValue(forKey: token)
        return true
    }

    mutating func release(_ token: Int) -> [Int] {
        guard let entry = registrations[token], held[entry.action] == token else { return [] }
        held.removeValue(forKey: entry.action)
        if entry.deferred { registrations.removeValue(forKey: token); return [token] }
        return []
    }
    mutating func stop() -> [Int] {
        let tokens = Array(registrations.keys)
        registrations.removeAll(); held.removeAll()
        return tokens
    }
}
