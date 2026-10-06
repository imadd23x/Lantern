import Foundation

enum ShortcutAction: String, CaseIterable, Codable, Sendable {
    case visibility, attention, nextProvider, previousProvider, mute

    var title: String {
        switch self {
        case .visibility: "Show or hide Lantern"
        case .attention: "Next attention request"
        case .nextProvider: "Next agent filter"
        case .previousProvider: "Previous agent filter"
        case .mute: "Mute or unmute alerts"
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
        .visibility: Self(keyCode: 37, modifiers: .standard, keyName: "L"),
        .attention: Self(keyCode: 0, modifiers: .standard, keyName: "A"),
        .nextProvider: Self(keyCode: 30, modifiers: .standard, keyName: "]"),
        .previousProvider: Self(keyCode: 33, modifiers: .standard, keyName: "["),
        .mute: Self(keyCode: 46, modifiers: .standard, keyName: "M"),
    ]
}
