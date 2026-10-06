import SwiftUI
import LanternCore

/// Space UI's text-plus-indicator treatment, driven solely by actual agent events.
struct SessionStatusBadge: View {
    let phase: EventKind
    @LanternReducedMotion private var reducedMotion

    private var active: Bool { phase == .thinking || phase == .working }
    private var color: Color {
        switch phase {
        case .approval, .attention: Palette.accent
        case .failed: Color(red: 1, green: 0.5, blue: 0.48)
        case .finished: .mint
        case .thinking, .working: Color(red: 0.65, green: 0.82, blue: 1)
        default: Palette.subtle
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "circle.fill").font(.system(size: 5))
                .symbolEffect(.pulse, isActive: active && !reducedMotion)
                .accessibilityHidden(true)
            Text(Self.label(for: phase)).font(.system(size: 9, weight: .medium))
        }
        .foregroundStyle(color).padding(.horizontal, 7).padding(.vertical, 4)
        .background(color.opacity(0.08), in: Capsule())
        .overlay(Capsule().stroke(color.opacity(0.12), lineWidth: 1))
        .accessibilityElement(children: .ignore).accessibilityLabel(Self.label(for: phase))
    }

    static func label(for phase: EventKind) -> String {
        switch phase {
        case .idle: "Ready"
        case .thinking: "Thinking"
        case .working: "Working"
        case .approval: "Approval"
        case .attention: "Needs you"
        case .finished: "Complete"
        case .failed: "Error"
        case .ended: "Ended"
        }
    }
}
