import AppKit
import SwiftUI

struct LanternEmblem: View {
    private static let image = Bundle.module.url(forResource: "LanternEmblem", withExtension: "png")
        .flatMap { NSImage(contentsOf: $0) }

    var body: some View {
        if let image = Self.image {
            Image(nsImage: image).renderingMode(.template).resizable().scaledToFit()
                .foregroundStyle(Palette.accent).accessibilityHidden(true)
        }
    }
}

/// Arc Empty States' quiet illustration/card/copy/action hierarchy, driven by real hook state.
struct AgentEmptyState: View {
    let title: String
    let explanation: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            LanternEmblem().frame(width: 44, height: 44).padding(.bottom, 2)
            Text(title).font(.system(size: 15, weight: .medium, design: .rounded))
            Text(explanation).font(.system(size: 12)).foregroundStyle(Palette.subtle)
                .multilineTextAlignment(.center).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            Button(actionTitle, action: action).buttonStyle(LanternButtonStyle(kind: .secondary))
                .padding(.top, 2)
        }
        .padding(.horizontal, 24).frame(maxWidth: .infinity).frame(height: PanelLayout.emptyHeight)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.border))
    }
}
