import Foundation
import CoreFoundation

/// A self-contained, bounded snapshot makes installation reversible without a second state file.
public enum StatusLineConfiguration {
    private static let separator = " --provider claude --usage --previous-status-line '"
    private static let ending = "' # lantern-usage-v1"

    public static func isInstalled(original: Data?) throws -> Bool {
        try owned(HookConfiguration.configurationRoot(original)["statusLine"]) != nil
    }

    public static func preview(original: Data?, relayPath: String, remove: Bool) throws -> ConfigurationPreview {
        try validatePath(relayPath)
        var root = try HookConfiguration.configurationRoot(original)
        let current = root["statusLine"]
        let prior = try owned(current)
        if remove, prior == nil { return ConfigurationPreview(original: original, updated: original ?? Data("{}".utf8)) }
        let snapshot = try prior ?? encode(current)
        let record = try decode(snapshot)
        if remove {
            if record["present"] as? Bool == true { root["statusLine"] = record["value"] }
            else { root.removeValue(forKey: "statusLine") }
        } else { root["statusLine"] = try wrapper(snapshot: snapshot, relayPath: relayPath) }
        return ConfigurationPreview(original: original, updated: try JSONSerialization.data(
            withJSONObject: root, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]))
    }

    public static func previousCommand(snapshot: String) throws -> String? {
        let record = try decode(snapshot)
        return (record["value"] as? [String: Any])?["command"] as? String
    }

    private static func encode(_ value: Any?) throws -> String {
        try validateValue(value)
        var record: [String: Any] = ["present": value != nil]
        if let value { record["value"] = value }
        let bytes = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys, .withoutEscapingSlashes])
        guard bytes.count <= 48_000 else { throw ConfigurationError.malformed }
        return bytes.base64EncodedString()
    }

    private static func decode(_ snapshot: String) throws -> [String: Any] {
        guard snapshot.count <= 64_000, let bytes = Data(base64Encoded: snapshot), bytes.count <= 48_000,
              bytes.base64EncodedString() == snapshot,
              let record = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              let present = record["present"] as? NSNumber, CFGetTypeID(present) == CFBooleanGetTypeID(),
              Set(record.keys) == (present.boolValue ? ["present", "value"] : ["present"]) else {
            throw ConfigurationError.malformed
        }
        try validateValue(record["value"])
        return record
    }

    private static func validateValue(_ value: Any?) throws {
        guard let value, !(value is NSNull) else { return }
        guard let line = value as? [String: Any], line["type"] as? String == "command",
              let command = line["command"] as? String, !command.isEmpty, !command.contains("\0") else {
            throw ConfigurationError.malformed
        }
    }

    private static func validatePath(_ path: String) throws {
        guard path.hasPrefix("/"), path.count <= 4096, !path.contains("\n"), !path.contains("\0") else {
            throw ConfigurationError.unsafeTarget
        }
    }

    private static func wrapper(snapshot: String, relayPath: String) throws -> [String: Any] {
        let record = try decode(snapshot)
        var line = record["value"] as? [String: Any] ?? [:]
        line["type"] = "command"
        line["command"] = ShellArgument.quote(relayPath) + separator + snapshot + ending
        return line
    }

    private static func owned(_ value: Any?) throws -> String? {
        guard let line = value as? [String: Any], let command = line["command"] as? String,
              command.hasSuffix(ending), let split = command.range(of: separator, options: .backwards) else { return nil }
        let quotedPath = String(command[..<split.lowerBound])
        guard quotedPath.hasPrefix("'"), quotedPath.hasSuffix("'") else { return nil }
        let path = String(quotedPath.dropFirst().dropLast()).replacingOccurrences(of: "'\\''", with: "'")
        try validatePath(path)
        guard ShellArgument.quote(path) == quotedPath else { return nil }
        let snapshot = String(command[split.upperBound...].dropLast(ending.count))
        let expected = try wrapper(snapshot: snapshot, relayPath: path)
        // An editor changed this wrapper's fields: refuse to overwrite those edits on removal/install.
        let options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
        guard try JSONSerialization.data(withJSONObject: line, options: options)
                == JSONSerialization.data(withJSONObject: expected, options: options) else { throw ConfigurationError.changed }
        return snapshot
    }
}
