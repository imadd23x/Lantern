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
    private static let marker = " # lantern-managed-v1"
    private static let events = ["SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
                                 "PostToolUse", "Stop", "SessionEnd", "SubagentStart", "SubagentStop"]

    public static func preview(original: Data?, provider: AgentProvider, relayPath: String, remove: Bool) throws -> ConfigurationPreview {
        guard relayPath.hasPrefix("/"), !relayPath.contains("\n"), !relayPath.contains("\0") else { throw ConfigurationError.unsafeTarget }
        var root: [String: Any] = [:]
        if let original {
            guard original.count <= 2_000_000,
                  let parsed = try? JSONSerialization.jsonObject(with: original) as? [String: Any] else { throw ConfigurationError.malformed }
            root = parsed
        }
        if let value = root["hooks"], !(value is [String: Any]) { throw ConfigurationError.malformed }
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
            var names = events
            if provider == .codex { names.append("Interrupt") }
            else { names.append(contentsOf: ["Notification", "PostToolUseFailure", "StopFailure"]) }
            for event in names {
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
