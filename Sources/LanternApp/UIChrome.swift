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
    enum Kind { case primary, secondary, toolbar, row }
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
    private var radius: CGFloat { kind == .row ? 15 : 10 }
    private var compactControl: Bool { controlSize == .small || controlSize == .mini }
    private var fill: Color {
        switch kind {
        case .primary: Palette.accent.opacity(highlighted ? 0.88 : 1)
        case .secondary, .row: highlighted ? Color.white.opacity(0.085) : Palette.card
        case .toolbar: Color.white.opacity(pressed ? 0.14 : highlighted ? 0.09 : 0)
        }
    }
    private var edge: Color {
        focused && enabled ? Palette.accent.opacity(0.8)
            : kind == .toolbar ? Color.white.opacity(highlighted ? 0.12 : 0)
            : Color.white.opacity(highlighted ? 0.18 : 0.09)
    }

    var body: some View {
        content
            .padding(.horizontal, kind == .row || kind == .toolbar ? 0 : compactControl ? 10 : 12)
            .padding(.vertical, kind == .row || kind == .toolbar ? 0 : compactControl ? 4 : 7)
            .frame(minWidth: kind == .toolbar ? 28 : nil,
                   minHeight: kind == .toolbar ? 28 : kind == .row ? nil : compactControl ? 24 : 32)
            .foregroundStyle(kind == .primary ? Color.black : kind == .toolbar && !highlighted ? Palette.subtle : .white)
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(edge, lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .opacity(enabled ? 1 : 0.42)
            .scaleEffect(enabled && pressed && !reducedMotion ? (kind == .row ? 0.995 : 0.98) : 1)
            .animation(LanternMotion.feedback(reduced: reducedMotion), value: pressed)
            .animation(LanternMotion.feedback(reduced: reducedMotion), value: highlighted)
            .onHover { hovered = $0 }
    }
}
