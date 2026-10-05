import SwiftUI
import LanternCore

/// Arc Segmented Control: stationary labels/counts and a shared rounded selection surface.
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
        HStack(spacing: 4) {
            ForEach(Option.allCases, id: \.self) { option in
                let selected = selection == option.provider
                let count = sessions.filter { option.provider == nil || $0.id.provider == option.provider }.count
                Button { select(option) } label: {
                    HStack(spacing: 6) {
                        Text(option.label).font(.system(size: 11, weight: .medium))
                        Text("\(count)").font(.system(size: 9, design: .monospaced)).monospacedDigit()
                            .foregroundStyle(selected ? .white.opacity(0.8) : Palette.subtle)
                    }
                    .padding(.horizontal, 8).frame(maxWidth: .infinity).frame(height: 32)
                    .foregroundStyle(selected ? .white : Palette.subtle)
                    .background {
                        if selected {
                            if reducedMotion { selectionSurface }
                            else { selectionSurface.matchedGeometryEffect(id: "filter", in: highlight) }
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Palette.amber.opacity(focused == option ? 0.65 : 0), lineWidth: 1))
                    .contentShape(RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain).focusable(selected).focusEffectDisabled().focused($focused, equals: option)
                .accessibilityLabel(option.label).accessibilityValue("\(count) \(count == 1 ? "session" : "sessions")")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4).background(.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.border, lineWidth: 1))
        .animation(LanternMotion.selection(reduced: reducedMotion), value: selection)
        .onKeyPress(keys: [.leftArrow, .rightArrow, .upArrow, .downArrow, .home, .end]) { key in
            let current = Option.allCases.first { $0.provider == selection } ?? .all
            let index: Int
            switch key.key {
            case .home: index = 0
            case .end: index = Option.allCases.count - 1
            case .leftArrow, .upArrow: index = (current.rawValue + Option.allCases.count - 1) % Option.allCases.count
            default: index = (current.rawValue + 1) % Option.allCases.count
            }
            select(Option.allCases[index])
            return .handled
        }
    }

    private var selectionSurface: some View {
        RoundedRectangle(cornerRadius: 9).fill(Color.white.opacity(0.10))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.white.opacity(0.10), lineWidth: 1))
            .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
            .allowsHitTesting(false)
    }

    private func select(_ option: Option) {
        // Keep the animation inside this control; filtering the parent list is immediate.
        selection = option.provider
        focused = option
    }
}
