import SwiftUI
import LanternCore

struct UsageSettingsView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var preferences: DesktopPreferences
    @ViewState private var installed = false
    @ViewState private var preview: ConfigurationPreview?
    @ViewState private var showingPreview = false
    @ViewState private var removing = false
    @ViewState private var message: String?
    @ViewState private var error: String?

    private var canConfigure: Bool {
        InstalledApplication.permitsConfiguration(isDemo: model.isDemo)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Toggle("Show Claude usage in Lantern", isOn: $preferences.usageDisplayEnabled).toggleStyle(.switch)
            VStack(spacing: 20) {
                UsageWindowView(title: "Five-hour limit", window: model.claudeUsage.fiveHour, now: model.now)
                UsageWindowView(title: "Weekly limit", window: model.claudeUsage.sevenDay, now: model.now)
            }.padding(18).background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.border))
            Text("Usage comes from Claude's local status-line data. Native VS Code panel sessions may not supply it. A missing window is unavailable; values become stale after 15 minutes or await refresh when their reset passes.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            Text(installed ? "Status-line relay configured" : "Status-line relay not configured")
                .font(.system(size: 13, weight: .medium))
            Text("Lantern preserves your existing status-line command. Changes use an exact backup and restore only an unchanged Lantern wrapper. No credentials or paid model calls are used.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            HStack {
                Button(installed ? "Review relay…" : "Review connection…") { prepare(remove: false) }
                    .buttonStyle(LanternButtonStyle(kind: .secondary))
                if installed {
                    Button("Remove relay…") { prepare(remove: true) }.buttonStyle(LanternButtonStyle(kind: .secondary))
                }
            }
            if let message { Text(message).font(.system(size: 11)).foregroundStyle(Palette.accent).textSelection(.enabled) }
            if let error { Text(error).font(.system(size: 12)).foregroundStyle(.yellow) }
            Link("Claude status-line documentation ↗", destination: URL(string: "https://code.claude.com/docs/en/statusline")!)
                .font(.system(size: 12))
        }.onAppear(perform: refresh)
            .sheet(isPresented: $showingPreview) {
                if let preview {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(removing ? "Remove usage relay" : "Connect Claude usage").font(.system(size: 20, weight: .semibold))
                        Text("Only the statusLine setting changes. Existing agent hooks and other settings are preserved.")
                            .font(.system(size: 12)).foregroundStyle(Palette.subtle)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                previewText("Current", bytes: preview.original)
                                previewText("Proposed", bytes: preview.updated)
                            }
                        }
                        if !canConfigure { Text("Apply from the installed Lantern app. Review builds cannot change connections.").font(.system(size: 11)).foregroundStyle(.yellow) }
                        HStack {
                            Button("Cancel") { showingPreview = false }.buttonStyle(LanternButtonStyle(kind: .secondary))
                            Spacer()
                            Button(removing ? "Back up and remove" : "Back up and connect") { apply(preview) }
                                .buttonStyle(LanternButtonStyle(kind: .primary)).disabled(!canConfigure)
                        }
                    }.padding(24).frame(width: 520, height: 540).background(Palette.background).preferredColorScheme(.dark)
                }
            }
    }

    private func refresh() {
        do { installed = try StatusLineConfiguration.isInstalled(original: ConfigurationTransaction.read(model.configurationURL(for: .claude))) }
        catch { self.error = error.localizedDescription }
    }

    private func prepare(remove: Bool) {
        guard remove || FileManager.default.isExecutableFile(atPath: model.relayPath) else {
            error = "The Lantern relay is missing or not executable. Reinstall Lantern before connecting usage."
            return
        }
        do {
            let original = try ConfigurationTransaction.read(model.configurationURL(for: .claude))
            preview = try StatusLineConfiguration.preview(original: original, relayPath: model.relayPath, remove: remove)
            removing = remove; error = nil; showingPreview = true
        } catch { self.error = error.localizedDescription }
    }

    private func apply(_ preview: ConfigurationPreview) {
        guard canConfigure else { return }
        guard removing || FileManager.default.isExecutableFile(atPath: model.relayPath) else {
            error = "The Lantern relay is missing or not executable. Reinstall Lantern before connecting usage."
            showingPreview = false; return
        }
        do {
            let backup = try ConfigurationTransaction.apply(preview, to: model.configurationURL(for: .claude))
            message = backup.map { "Saved backup: " + $0.lastPathComponent } ?? "Configured. No previous settings file existed."
            error = nil; showingPreview = false; refresh()
        } catch { self.error = error.localizedDescription; showingPreview = false }
    }

    private func previewText(_ title: String, bytes: Data?) -> some View {
        let root = bytes.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        let value = root?["statusLine"]
        let text = value.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed, .withoutEscapingSlashes]) }
            .flatMap { String(data: $0, encoding: .utf8) } ?? "Not configured"
        return VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 12, weight: .semibold))
            Text(text).font(.system(size: 11, design: .monospaced)).textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading).padding(12).background(Palette.card, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
