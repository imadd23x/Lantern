import SwiftUI
import LanternCore

/// A moving selection surface with stationary labels, adapted from Arc/Planes design references.
struct ProviderFilter: View {
    @Binding var selection: AgentProvider?
    let sessions: [AgentSession]
    @Namespace private var highlight
    @FocusState private var focused: Option?
    @LanternReducedMotion private var reducedMotion

    private enum Option: Int, CaseIterable {
        case all, codex, claude
        var provider: AgentProvider? {
            switch self { case .all: nil; case .codex: .codex; case .claude: .claude }
        }
        var label: String { provider?.title ?? "All agents" }
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Option.allCases, id: \.self) { option in
                let selected = selection == option.provider
                let count = sessions.filter { option.provider == nil || $0.id.provider == option.provider }.count
                Button { select(option) } label: {
                    HStack(spacing: 6) {
                        Text(option.label).font(.system(size: 11, weight: .medium))
                        Text("\(count)").font(.system(size: 9, design: .monospaced)).monospacedDigit()
                            .foregroundStyle(selected ? .white.opacity(0.8) : Palette.subtle)
                    }
                    .padding(.horizontal, 11).frame(height: 30)
                    .foregroundStyle(selected ? .white : Palette.subtle)
                    .background {
                        if selected {
                            if reducedMotion { selectionSurface }
                            else { selectionSurface.matchedGeometryEffect(id: "filter", in: highlight) }
                        }
                    }
                    .overlay(Capsule().stroke(Palette.amber.opacity(focused == option ? 0.65 : 0), lineWidth: 1))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain).focusable().focusEffectDisabled().focused($focused, equals: option)
                .accessibilityLabel(option.label).accessibilityValue("\(count) \(count == 1 ? "session" : "sessions")")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(3).background(.black.opacity(0.2), in: Capsule())
        .overlay(Capsule().stroke(Palette.border, lineWidth: 1))
        .animation(LanternMotion.selection(reduced: reducedMotion), value: selection)
        .onKeyPress(keys: [.leftArrow, .rightArrow, .home, .end]) { key in
            let current = Option.allCases.first { $0.provider == selection } ?? .all
            let index: Int
            switch key.key {
            case .home: index = 0
            case .end: index = Option.allCases.count - 1
            case .leftArrow: index = (current.rawValue + Option.allCases.count - 1) % Option.allCases.count
            default: index = (current.rawValue + 1) % Option.allCases.count
            }
            select(Option.allCases[index])
            return .handled
        }
    }

    private var selectionSurface: some View {
        Capsule().fill(Color.white.opacity(0.10))
            .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
            .allowsHitTesting(false)
    }

    private func select(_ option: Option) {
        // Keep the animation inside this control; filtering the parent list is immediate.
        selection = option.provider
        focused = option
    }
}
