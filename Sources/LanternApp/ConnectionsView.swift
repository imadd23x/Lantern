import SwiftUI
import LanternCore
import LanternTransport

struct ConnectionsView: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @ViewState private var provider: AgentProvider = .codex
    @ViewState private var preview: ConfigurationPreview?
    @ViewState private var removing = false
    @ViewState private var message = ""
    @ViewState private var error = ""
    @ViewState private var showingBefore = false

    private var target: URL { model.configurationURL(for: provider) }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("Connect your agents").font(.system(size: 20, weight: .semibold, design: .rounded))
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }
            Text("Lantern uses local hooks to watch sessions and return the decisions you make here.")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Picker("Agent", selection: $provider) {
                ForEach(AgentProvider.allCases, id: \.self) { Text($0.title).tag($0) }
            }.pickerStyle(.segmented).onChange(of: provider) { _, _ in preview = nil; error = ""; message = "" }
            Text(model.installedProviders.contains(provider) ? "Hooks installed · Waiting for agent activity"
                 : model.connectionWarnings[provider] ?? "Hooks not installed for this Lantern app")
                .font(.system(size: 11)).foregroundStyle(model.installedProviders.contains(provider) ? .mint : .secondary)
            Text(target.path).font(.system(size: 10, design: .monospaced)).textSelection(.enabled)
            HStack {
                Button("Preview connection") { makePreview(remove: false) }
                Button("Preview removal") { makePreview(remove: true) }
            }.controlSize(.small).buttonStyle(LanternButtonStyle(kind: .secondary))
            if let preview {
                Picker("View", selection: $showingBefore) {
                    Text("Proposed settings").tag(false)
                    Text("Current settings").tag(true)
                }.pickerStyle(.segmented)
                ScrollView([.vertical, .horizontal]) {
                    Text(String(decoding: showingBefore ? preview.original ?? Data("(No existing file)".utf8) : preview.updated, as: UTF8.self))
                        .font(.system(size: 10, design: .monospaced)).textSelection(.enabled).padding(10)
                }.frame(height: 165).background(.black.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 10))
                Button(removing ? "Apply removal" : "Back up and connect") { apply(preview) }
                    .buttonStyle(LanternButtonStyle(kind: .primary)).controlSize(.small)
                    .disabled(model.isDemo)
            } else {
                Spacer(minLength: 0)
                Text("Review the exact change before applying. Existing hooks stay in place; a verified backup is created first.")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            if !message.isEmpty { Text(message).font(.system(size: 11)).foregroundStyle(.mint).textSelection(.enabled) }
            if !error.isEmpty { Text(error).font(.system(size: 11)).foregroundStyle(.orange) }
            Text(provider == .codex
                 ? "After connecting, open /hooks in Codex CLI to review and trust the Lantern definitions. Start a new desktop session so its host reloads the hooks. Managed policy can restrict hooks."
                 : "After connecting, restart your Claude Code session in VS Code so it loads the hooks. Project or managed settings may disable user hooks.")
                .font(.system(size: 10)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            if model.isDemo { Text("Demo mode: configuration writes are disabled.").font(.system(size: 10)).foregroundStyle(Palette.amber) }
        }.padding(22).frame(width: 520, height: 510).preferredColorScheme(.dark)
    }

    private func makePreview(remove: Bool) {
        error = ""; message = ""; removing = remove; showingBefore = false
        do {
            guard FileManager.default.isExecutableFile(atPath: model.relayPath) else {
                throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "The packaged hook executable is missing. Build Lantern.app first."])
            }
            preview = try HookConfiguration.preview(original: ConfigurationTransaction.read(target), provider: provider,
                                                      relayPath: model.relayPath, remove: remove)
        } catch { preview = nil; self.error = error.localizedDescription }
    }

    private func apply(_ preview: ConfigurationPreview) {
        do {
            let backup = try ConfigurationTransaction.apply(preview, to: target)
            message = "\(removing ? "Removed Lantern hooks." : "Connected. Follow the reload steps below.")" + (backup.map { "\nBackup: \($0.path)" } ?? "")
            self.preview = nil; error = ""
            model.refreshConnections()
        } catch { self.error = error.localizedDescription }
    }
}
