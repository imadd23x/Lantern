import SwiftUI
import ServiceManagement

struct DesktopSettingsView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var preferences: DesktopPreferences
    @ObservedObject var shortcuts: ShortcutController
    @ObservedObject var login: LoginItemController
    let onClose: () -> Void
    @ViewState private var section = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Lantern settings").font(.system(size: 22, weight: .semibold))
            Picker("Settings section", selection: $section) {
                Text("General").tag(0)
                Text("Shortcuts").tag(1)
                Text("Usage").tag(2)
            }.pickerStyle(.segmented)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if section == 0 { general }
                    else if section == 1 { shortcutSettings }
                    else { UsageSettingsView(model: model, preferences: preferences) }
                }.padding(.vertical, 4)
            }
            HStack {
                Button("Agent connections…") { model.showConnections = true; model.showCompanion(expanded: true) }
                    .buttonStyle(LanternButtonStyle(kind: .secondary))
                Spacer()
                Button("Done", action: onClose).buttonStyle(LanternButtonStyle(kind: .primary))
            }
        }
        .padding(24).foregroundStyle(.white).background(Palette.background)
        .preferredColorScheme(.dark).tint(Palette.accent)
    }

    private var shortcutSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Enable global shortcuts", isOn: $preferences.shortcutsEnabled).toggleStyle(.switch)
            Text("Click a shortcut, then press your preferred combination. Escape cancels. Command–Return allows only the displayed, unexpired request. Command–Option–H hides Lantern. Allow is inactive in other apps when no actionable card is visible.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            ForEach(ShortcutAction.allCases, id: \.self) { action in
                if let binding = preferences.bindings[action] {
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Toggle(action.title, isOn: Binding(get: { binding.enabled }, set: {
                                var next = binding; next.enabled = $0; shortcuts.update(next, for: action)
                            })).toggleStyle(.checkbox)
                            Spacer()
                            ShortcutRecorder(action: action, controller: shortcuts).frame(width: 150, height: 32)
                        }
                        if let error = shortcuts.error(for: action) { Text(error).font(.system(size: 11)).foregroundStyle(.yellow) }
                    }
                    .padding(12).background(Palette.card, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.border))
                }
            }
        }
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Hide the pill when idle", isOn: $preferences.autoHideEnabled)
            Picker("After", selection: Binding(get: { preferences.idleDelay }, set: { preferences.setIdleDelay($0) })) {
                Text("15 seconds").tag(15.0)
                Text("30 seconds").tag(30.0)
                Text("1 minute").tag(60.0)
                Text("2 minutes").tag(120.0)
                Text("5 minutes").tag(300.0)
            }.disabled(!preferences.autoHideEnabled)
            Toggle("Keep Lantern visible", isOn: $preferences.pinned)
                .help("Pin the idle pill. Explicit Hide still works.")
            Text("Active work and requests keep Lantern visible. Hover its top edge to reveal an automatically hidden pill.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            Divider()
            Toggle("Launch at login", isOn: Binding(get: { login.enabled }, set: { login.setEnabled($0) }))
                .disabled(!login.supported)
            if login.status == .requiresApproval {
                Text("Requires your approval in macOS Login Items.").font(.system(size: 12)).foregroundStyle(Palette.subtle)
                Button("Open Login Items…") { SMAppService.openSystemSettingsLoginItems() }
                    .buttonStyle(LanternButtonStyle(kind: .secondary))
            }
            if let error = login.error { Text(error).font(.system(size: 12)).foregroundStyle(.yellow) }
            if !login.supported {
                Text("Launch at login is managed from the installed Lantern app.").font(.system(size: 12)).foregroundStyle(Palette.subtle)
            }
        }
        .toggleStyle(.switch).padding(18).background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.border))
    }
}
