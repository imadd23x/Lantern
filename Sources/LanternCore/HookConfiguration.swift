import Foundation

public struct ConfigurationPreview: Sendable {
    public let original: Data?
    public let updated: Data
}

public enum ConfigurationError: Error, LocalizedError {
    case malformed, changed, unsafeTarget, backupFailed
    public var errorDescription: String? {
        switch self {
        case .malformed: "Existing hooks have an invalid shape. Lantern left them unchanged."
        case .changed: "Settings changed since this preview. Refresh the preview and try again."
        case .unsafeTarget: "This configuration is a symbolic link or an unsupported file. Choose a regular configuration file."
        case .backupFailed: "A verified backup could not be created. Settings were not replaced."
        }
    }
}

public enum ShellArgument {
    public static func quote(_ value: String) -> String { "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'" }
}

public enum HookConfiguration {
    public enum Installation: Sendable { case absent, incomplete, installed }
    private static let marker = " # lantern-managed-v1"
    private static let events = ["SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
                                 "PostToolUse", "Stop", "SessionEnd", "SubagentStart", "SubagentStop"]

    /// Read-only inspection of the exact definitions this app installs. Trust and live delivery are separate.
    public static func installation(original: Data?, provider: AgentProvider, relayPath: String) throws -> Installation {
        guard let original else { return .absent }
        let root = try configurationRoot(original)
        let hooks = root["hooks"] as? [String: Any] ?? [:]
        let command = ShellArgument.quote(relayPath) + " --provider \(provider.rawValue)" + marker
        let covered = eventNames(provider).filter { event in
            (hooks[event] as? [[String: Any]] ?? []).contains { group in
                guard (group["matcher"] as? String ?? "").isEmpty else { return false }
                return (group["hooks"] as? [[String: Any]] ?? []).contains {
                    $0["type"] as? String == "command" && $0["command"] as? String == command
                }
            }
        }
        guard !covered.isEmpty else { return .absent }
        if provider == .claude, root["disableAllHooks"] as? Bool == true { return .incomplete }
        return covered.count == eventNames(provider).count ? .installed : .incomplete
    }

    private static func eventNames(_ provider: AgentProvider) -> [String] {
        events + (provider == .codex ? ["Interrupt"] : ["Notification", "PostToolUseFailure", "StopFailure"])
    }

    static func configurationRoot(_ original: Data?) throws -> [String: Any] {
        guard let original else { return [:] }
        guard original.count <= 2_000_000,
              let root = try? JSONSerialization.jsonObject(with: original) as? [String: Any] else {
            throw ConfigurationError.malformed
        }
        if let hooks = root["hooks"] {
            guard let hooks = hooks as? [String: Any] else { throw ConfigurationError.malformed }
            for value in hooks.values {
                guard let groups = value as? [[String: Any]] else { throw ConfigurationError.malformed }
                for group in groups {
                    guard let handlers = group["hooks"] as? [[String: Any]],
                          handlers.allSatisfy({ $0["type"] is String }) else { throw ConfigurationError.malformed }
                }
            }
        }
        return root
    }

    public static func preview(original: Data?, provider: AgentProvider, relayPath: String, remove: Bool) throws -> ConfigurationPreview {
        guard relayPath.hasPrefix("/"), !relayPath.contains("\n"), !relayPath.contains("\0") else { throw ConfigurationError.unsafeTarget }
        var root = try configurationRoot(original)
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        for (event, value) in hooks {
            guard let groups = value as? [[String: Any]] else { throw ConfigurationError.malformed }
            var cleaned: [[String: Any]] = []
            for var group in groups {
                guard let handlers = group["hooks"] as? [[String: Any]],
                      handlers.allSatisfy({ $0["type"] is String }) else { throw ConfigurationError.malformed }
                let kept = handlers.filter { handler in
                    guard let command = handler["command"] as? String else { return true }
                    return !(command.hasSuffix(marker) && command.contains(" --provider \(provider.rawValue)"))
                }
                if !kept.isEmpty { group["hooks"] = kept; cleaned.append(group) }
            }
            if cleaned.isEmpty { hooks.removeValue(forKey: event) } else { hooks[event] = cleaned }
        }
        if !remove {
            let command = ShellArgument.quote(relayPath) + " --provider \(provider.rawValue)" + marker
            for event in eventNames(provider) {
                var groups = hooks[event] as? [[String: Any]] ?? []
                var handler: [String: Any] = ["type": "command", "command": command,
                                               "timeout": event == "PermissionRequest" ? 120 : 3]
                if provider == .codex { handler["statusMessage"] = event == "PermissionRequest" ? "Waiting for your answer in Lantern" : "Updating Lantern" }
                groups.append(["hooks": [handler]])
                hooks[event] = groups
            }
        }
        if !hooks.isEmpty || root["hooks"] != nil { root["hooks"] = hooks }
        let updated = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        return ConfigurationPreview(original: original, updated: updated)
    }
}
