import SwiftUI
import LanternCore

/// Arc Badge semantic tones; state always comes from agent events, never inferred progress.
struct SessionStatusBadge: View {
    let phase: EventKind
    @LanternReducedMotion private var reducedMotion

    private var color: Color {
        switch phase {
        case .approval, .attention: Palette.warning
        case .failed: Palette.danger
        case .finished: Palette.accentText
        case .thinking, .working: Color(red: 0.60, green: 0.76, blue: 1)
        default: Palette.subtle
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: phase == .finished ? "checkmark" : "circle.fill")
                .font(.system(size: phase == .finished ? 8 : 5, weight: .semibold))
                .symbolEffect(.pulse, isActive: [.thinking, .working].contains(phase) && !reducedMotion)
                .accessibilityHidden(true)
            Text(Self.label(for: phase)).font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(color).padding(.horizontal, 8).frame(height: 22)
        .background(color.opacity(0.10), in: Capsule())
        .overlay(Capsule().stroke(color.opacity(0.23), lineWidth: 1))
        .animation(LanternMotion.feedback(reduced: reducedMotion), value: phase)
        .accessibilityElement(children: .ignore).accessibilityLabel(Self.label(for: phase))
    }

    static func label(for phase: EventKind) -> String {
        switch phase {
        case .idle: "Ready"
        case .thinking: "Thinking"
        case .working: "Working"
        case .approval: "Approval"
        case .attention: "Needs attention"
        case .finished: "Complete"
        case .failed: "Error"
        case .ended: "Ended"
        }
    }
}
