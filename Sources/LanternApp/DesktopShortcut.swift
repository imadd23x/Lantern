import Foundation

enum ShortcutAction: String, CaseIterable, Codable, Sendable {
    case allowOnce, hide

    var title: String {
        switch self {
        case .allowOnce: "Allow once"
        case .hide: "Hide Lantern"
        }
    }
}

struct ShortcutModifiers: OptionSet, Codable, Hashable, Sendable {
    let rawValue: UInt8
    static let control = Self(rawValue: 1)
    static let option = Self(rawValue: 2)
    static let command = Self(rawValue: 4)
    static let shift = Self(rawValue: 8)
    static let standard: Self = [.control, .option, .command]
}

struct ShortcutBinding: Codable, Equatable, Sendable {
    var keyCode: UInt16
    var modifiers: ShortcutModifiers
    var keyName: String
    var enabled = true

    var isSafe: Bool {
        keyCode <= 126 && !keyName.isEmpty && keyName.count <= 12
            && !keyName.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) })
            && modifiers.rawValue & ~UInt8(15) == 0
            && !modifiers.intersection([.control, .option, .command]).isEmpty
    }
    var label: String {
        [(ShortcutModifiers.control, "⌃"), (.option, "⌥"), (.shift, "⇧"), (.command, "⌘")]
            .filter { modifiers.contains($0.0) }.map(\.1).joined() + keyName
    }

    func conflicts(with other: Self) -> Bool {
        enabled && other.enabled && keyCode == other.keyCode && modifiers == other.modifiers
    }

    static let defaults: [ShortcutAction: Self] = [
        .allowOnce: Self(keyCode: 36, modifiers: .command, keyName: "Return"),
        .hide: Self(keyCode: 4, modifiers: [.command, .option], keyName: "H"),
    ]
}
