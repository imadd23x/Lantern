import SwiftUI

struct ArcTab: Identifiable {
    let id: Int
    let title: String
    var count: Int? = nil
}

/// Arc navigation tabs: one gliding surface, stationary labels and roving keyboard selection.
struct ArcTabs: View {
    let tabs: [ArcTab]
    @Binding var selection: Int
    @Namespace private var highlight
    @FocusState private var focused: Int?
    @LanternReducedMotion private var reducedMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs) { tab in
                let selected = selection == tab.id
                Button { select(tab.id) } label: {
                    HStack(spacing: 6) {
                        Text(tab.title)
                        if let count = tab.count {
                            Text("\(count)").font(.system(size: 10, design: .monospaced)).monospacedDigit()
                                .foregroundStyle(Palette.subtle)
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .frame(maxWidth: .infinity).frame(height: 32)
                    .foregroundStyle(selected ? Palette.accentText : Palette.subtle)
                    .background {
                        if selected {
                            if reducedMotion { selectionSurface }
                            else { selectionSurface.matchedGeometryEffect(id: "selection", in: highlight) }

                        }
                    }
                }
                .buttonStyle(LanternButtonStyle(kind: .tab))
                .focusable(selected).focusEffectDisabled().focused($focused, equals: tab.id)
                .accessibilityLabel(tab.title)
                .accessibilityValue(tab.count.map { "\($0) sessions" } ?? (selected ? "Selected" : ""))
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4).background(Palette.inset, in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.border))
        .animation(LanternMotion.selection(reduced: reducedMotion), value: selection)
        .onKeyPress(keys: [.leftArrow, .rightArrow, .upArrow, .downArrow, .home, .end]) { key in
            guard !tabs.isEmpty else { return .ignored }
            let current = tabs.firstIndex { $0.id == selection } ?? 0
            let index: Int
            switch key.key {
            case .home: index = 0
            case .end: index = tabs.count - 1
            case .leftArrow, .upArrow: index = (current + tabs.count - 1) % tabs.count
            default: index = (current + 1) % tabs.count
            }
            select(tabs[index].id)
            return .handled
        }
    }

    private var selectionSurface: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Palette.raised)
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Palette.border))
            .shadow(color: .black.opacity(0.18), radius: 2, y: 1).allowsHitTesting(false)
    }

    private func select(_ id: Int) { selection = id; focused = id }
}
