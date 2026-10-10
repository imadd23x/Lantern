import SwiftUI

/// Arc's 42×24 fixed track, spring thumb and native press feedback, using native Toggle activation.
struct ArcSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: 12) {
                configuration.label.frame(maxWidth: .infinity, alignment: .leading)
                ArcSwitchTrack(on: configuration.isOn)
            }.font(.system(size: 12, weight: .medium))
        }
        .buttonStyle(LanternButtonStyle(kind: .switchRow))
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }.toggleStyle(.switch)
        }
    }
}

private struct ArcSwitchTrack: View {
    let on: Bool
    @Environment(\.isEnabled) private var enabled
    @LanternReducedMotion private var reducedMotion

    var body: some View {
        Capsule().fill(on ? Palette.accent : Color.white.opacity(0.15))
            .overlay(alignment: .leading) {
                Circle().fill(.white).frame(width: 18, height: 18)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    .offset(x: on ? 21 : 3)
            }
            .frame(width: 42, height: 24)
            .opacity(enabled ? 1 : 0.5)
            .animation(LanternMotion.selection(reduced: reducedMotion), value: on)
            .accessibilityHidden(true)
    }
}
