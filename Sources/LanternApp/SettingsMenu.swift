import SwiftUI

/// Arc User Menu adapted to local companion destinations, with no account or remote actions.
struct SettingsMenu: View {
    @ObservedObject var model: AppModel
    @FocusState private var focused: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                LanternEmblem().frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Lantern").font(.system(size: 13, weight: .semibold))
                    Text("Your desktop guardian").font(.system(size: 11)).foregroundStyle(Palette.subtle)
                }
            }.padding(10)
            Divider().overlay(Palette.border)
            destination("General", symbol: "slider.horizontal.3", index: 0) { open(.general) }
            destination("Shortcuts", symbol: "command", index: 1) { open(.shortcuts) }
            destination("Agent connections", symbol: "link", index: 2) {
                model.isSettingsMenuOpen = false
                model.showConnections = true
            }
        }
        .padding(6).frame(width: 248).background(Palette.background)
        .preferredColorScheme(.dark)
        .onAppear { focused = 0 }
        .onExitCommand { model.isSettingsMenuOpen = false }
        .onKeyPress(keys: [.upArrow, .downArrow, .home, .end]) { key in
            switch key.key {
            case .home: focused = 0
            case .end: focused = 2
            case .upArrow: focused = ((focused ?? 0) + 2) % 3
            default: focused = ((focused ?? 0) + 1) % 3
            }
            return .handled
        }
    }

    private func destination(_ title: String, symbol: String, index: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol).frame(width: 16).foregroundStyle(Palette.subtle)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 8)).foregroundStyle(Palette.subtle)
            }.font(.system(size: 12)).padding(.horizontal, 12).frame(height: 38)
        }.buttonStyle(LanternButtonStyle(kind: .menu))
            .focusable().focusEffectDisabled().focused($focused, equals: index)
    }

    private func open(_ section: SettingsSection) {
        model.isSettingsMenuOpen = false
        model.onSettingsRequest?(section)
    }
}
