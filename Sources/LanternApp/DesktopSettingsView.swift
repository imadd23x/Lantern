import SwiftUI
import ServiceManagement

// Shared destination selection lets the gear menu open the requested tab in the existing window.
enum SettingsSection: Int, CaseIterable {
    case general, shortcuts
    var title: String { self == .general ? "General" : "Shortcuts" }
}

@MainActor
final class SettingsSelection: ObservableObject {
    @Published var section = SettingsSection.general
}

struct DesktopSettingsView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var preferences: DesktopPreferences
    @ObservedObject var shortcuts: ShortcutController
    @ObservedObject var login: LoginItemController
    @ObservedObject var selection: SettingsSelection
    let onClose: () -> Void
    let onHeightChange: (CGFloat) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    LanternEmblem().frame(width: 28, height: 28)
                    Text("Lantern settings").font(.system(size: 20, weight: .semibold))
                }
                ArcTabs(tabs: SettingsSection.allCases.map { ArcTab(id: $0.rawValue, title: $0.title) },
                        selection: Binding(get: { selection.section.rawValue },
                                           set: { selection.section = SettingsSection(rawValue: $0) ?? .general }))
                Group {
                    if selection.section == .general { general }
                    else { shortcutSettings }
                }.padding(.vertical, 2).frame(maxWidth: .infinity)
                HStack {
                    Button("Agent connections") { model.showConnections = true }
                        .buttonStyle(LanternButtonStyle(kind: .secondary))
                    Spacer()
                    Button("Done", action: onClose).buttonStyle(LanternButtonStyle(kind: .primary))
                }.font(.system(size: 12, weight: .medium))
            }
            .padding(22).frame(width: 500).fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: onHeightChange)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(.white).background(Palette.background)
        .preferredColorScheme(.dark).tint(Palette.accent)
    }

    private var shortcutSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Enable global shortcuts", isOn: $preferences.shortcutsEnabled).toggleStyle(ArcSwitchStyle())
            Text("Click a shortcut, press your combination, then release to save. Escape cancels.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            ForEach(ShortcutAction.allCases, id: \.self) { action in
                if let binding = preferences.bindings[action] {
                    VStack(alignment: .leading, spacing: 7) {
                        HStack(spacing: 12) {
                            Toggle(action.title, isOn: Binding(get: { binding.enabled }, set: {
                                var next = binding; next.enabled = $0; shortcuts.update(next, for: action)
                            })).toggleStyle(ArcSwitchStyle())
                            ShortcutRecorder(action: action, controller: shortcuts).frame(width: 132, height: 32)
                        }
                        if let error = shortcuts.error(for: action) {
                            Text(error).font(.system(size: 11)).foregroundStyle(Palette.warning)
                        }
                    }.padding(14).background(Palette.card, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.border))
                }
            }
        }
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Hide the pill when idle", isOn: $preferences.autoHideEnabled)
            HStack {
                Text("Hide after").font(.system(size: 12)).foregroundStyle(Palette.subtle)
                Spacer()
                Menu {
                    ForEach([15.0, 30, 60, 120, 300], id: \.self) { delay in
                        Button(delayTitle(delay)) { preferences.setIdleDelay(delay) }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(delayTitle(preferences.idleDelay))
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 9))
                    }.font(.system(size: 11, weight: .medium))
                }.menuStyle(.borderlessButton).fixedSize()
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Palette.raised, in: RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Palette.border))
                    .disabled(!preferences.autoHideEnabled)
            }
            Toggle("Keep Lantern visible", isOn: $preferences.pinned)
            Text("Work and requests keep Lantern visible. Hover its top edge to reveal an idle-hidden pill.")
                .font(.system(size: 11)).foregroundStyle(Palette.subtle).fixedSize(horizontal: false, vertical: true)
            Divider().overlay(Palette.border)
            Toggle("Launch at login", isOn: Binding(get: { login.enabled }, set: { login.setEnabled($0) }))
                .disabled(!login.supported)
            if login.status == .requiresApproval {
                Text("Requires approval in macOS Login Items.").font(.system(size: 11)).foregroundStyle(Palette.subtle)
                Button("Open Login Items") { SMAppService.openSystemSettingsLoginItems() }
                    .buttonStyle(LanternButtonStyle(kind: .secondary))
            }
            if let error = login.error { Text(error).font(.system(size: 11)).foregroundStyle(Palette.warning) }
            if !login.supported {
                Text("Managed from the installed app.").font(.system(size: 11)).foregroundStyle(Palette.subtle)
            }
        }
        .toggleStyle(ArcSwitchStyle()).padding(16).background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.border))
    }

    private func delayTitle(_ delay: Double) -> String {
        if delay < 60 { return "\(Int(delay)) seconds" }
        return "\(Int(delay / 60)) \(delay == 60 ? "minute" : "minutes")"
    }
}
