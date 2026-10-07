import SwiftUI

extension ConnectionStatus {
    var indicatorColor: Color {
        switch self {
        case .connected: Palette.accent
        case .connecting: .yellow
        case .disconnected, .failed: .red
        }
    }
}

private struct ReduceMotionOverride: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var lanternReduceMotion: Bool {
        get { self[ReduceMotionOverride.self] }
        set { self[ReduceMotionOverride.self] = newValue }
    }
}

/// Respect the OS preference, with a process-local override for UI verification.
@propertyWrapper
struct LanternReducedMotion: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var system
    @Environment(\.lanternReduceMotion) private var override
    var wrappedValue: Bool { system || override }
}

enum Palette {
    static let accent = Color(.sRGB, red: 6 / 255.0, green: 155 / 255.0, blue: 46 / 255.0, opacity: 1)
    static let background = Color(red: 0.065, green: 0.07, blue: 0.08)
    static let raised = Color(red: 0.14, green: 0.15, blue: 0.16)
    static let inset = Color.black.opacity(0.18)
    static let accentText = Color(red: 0.25, green: 0.82, blue: 0.40)
    static let warning = Color(red: 0.97, green: 0.71, blue: 0.34)
    static let danger = Color(red: 1, green: 0.48, blue: 0.46)
    static let card = Color.white.opacity(0.045)
    static let subtle = Color.white.opacity(0.55)
    static let border = Color.white.opacity(0.09)
}

/// Native timing choices inspired by Arc/Planes; web spring constants are not interchangeable.
enum LanternMotion {
    static func card(reduced: Bool) -> Animation? {
        reduced ? nil : .timingCurve(0.22, 1, 0.36, 1, duration: 0.32)
    }
    static func selection(reduced: Bool) -> Animation? {
        reduced ? nil : .spring(response: 0.32, dampingFraction: 0.92)
    }
    static func feedback(reduced: Bool) -> Animation? {
        reduced ? nil : .easeOut(duration: 0.12)
    }
}

/// Changes rendering only. SwiftUI Button still owns activation, cancellation and disabled behavior.
struct LanternButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, danger, ghost, toolbar, menuTrigger, menu, tab, switchRow, row }
    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        ControlSurface(kind: kind, pressed: configuration.isPressed, content: configuration.label)
    }
}

private struct ControlSurface: View {
    let kind: LanternButtonStyle.Kind
    let pressed: Bool
    let content: ButtonStyleConfiguration.Label
    @ViewState private var hovered = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.isFocused) private var focused
    @Environment(\.controlSize) private var controlSize
    @LanternReducedMotion private var reducedMotion

    private var highlighted: Bool { enabled && (hovered || focused || pressed) }
    private var radius: CGFloat { kind == .row ? 15 : 9 }
    private var compactControl: Bool { controlSize == .small || controlSize == .mini }
    private var unpadded: Bool { [.row, .toolbar, .menuTrigger, .menu, .tab, .switchRow].contains(kind) }
    private var fill: Color {
        switch kind {
        case .primary: Palette.accent.opacity(pressed ? 0.92 : highlighted ? 0.96 : 1)
        case .secondary, .danger, .row: highlighted ? Color.white.opacity(0.085) : Palette.card
        case .menu: highlighted ? Palette.accent.opacity(0.14) : .clear
        case .toolbar, .menuTrigger, .ghost, .tab, .switchRow:
            Color.white.opacity(pressed ? 0.12 : highlighted ? 0.055 : 0)
        }
    }
    private var edge: Color {
        if focused && enabled { return Palette.accent.opacity(0.8) }
        if kind == .danger && highlighted { return Palette.danger.opacity(0.6) }
        return unpadded && kind != .row ? .clear : Color.white.opacity(highlighted ? 0.18 : 0.09)
    }
    private var foreground: Color {
        if kind == .primary { return .black }
        if kind == .danger { return Palette.danger }
        if [.toolbar, .menuTrigger, .ghost].contains(kind) && !highlighted { return Palette.subtle }
        return .white
    }

    var body: some View {
        content
            .padding(.horizontal, unpadded ? 0 : compactControl ? 10 : 12)
            .padding(.vertical, unpadded ? 0 : compactControl ? 4 : 7)
            .frame(minWidth: [.toolbar, .menuTrigger].contains(kind) ? 28 : nil,
                   minHeight: [.toolbar, .menuTrigger].contains(kind) ? 28 : unpadded ? nil : compactControl ? 26 : 32)
            .foregroundStyle(foreground)
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(edge, lineWidth: focused ? 1.5 : 1))
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .opacity(enabled ? 1 : 0.5)
            .scaleEffect(enabled && pressed && !reducedMotion && kind != .menuTrigger && kind != .tab && kind != .switchRow
                         ? (kind == .row || kind == .menu ? 0.995 : 0.98) : 1)
            .animation(LanternMotion.feedback(reduced: reducedMotion), value: pressed)
            .animation(LanternMotion.feedback(reduced: reducedMotion), value: highlighted)
            .onHover { hovered = $0 }
    }
}
