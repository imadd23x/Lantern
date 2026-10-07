import SwiftUI
import LanternCore
import LanternTransport

struct ConnectionsView: View {
    @ObservedObject var model: AppModel
    let onClose: () -> Void
    let onHeightChange: (CGFloat) -> Void
    @ViewState private var provider: AgentProvider = .codex
    @ViewState private var preview: ConfigurationPreview?
    @ViewState private var removing = false
    @ViewState private var message = ""
    @ViewState private var error = ""
    @ViewState private var showingBefore = false

    private var target: URL { model.configurationURL(for: provider) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Connect your agents").font(.system(size: 19, weight: .semibold, design: .rounded))
                Spacer()
                Button("Done", action: onClose).buttonStyle(LanternButtonStyle(kind: .secondary))
                    .keyboardShortcut(.cancelAction)
            }
            Text("Local hooks bring agent activity and approval requests to Lantern.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle)
            ArcTabs(tabs: AgentProvider.allCases.enumerated().map { ArcTab(id: $0.offset, title: $0.element.title) },
                    selection: Binding(get: { provider == .codex ? 0 : 1 },
                                       set: { provider = AgentProvider.allCases[$0] }))
                .onChange(of: provider) { _, _ in preview = nil; error = ""; message = "" }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 7) {
                    Circle().fill(model.installedProviders.contains(provider) ? Palette.accent : Palette.warning)
                        .frame(width: 6, height: 6)
                    Text(model.installedProviders.contains(provider) ? "Hooks installed"
                         : model.connectionWarnings[provider] ?? "Not connected")
                        .font(.system(size: 12, weight: .medium))
                }
                Text((target.path as NSString).abbreviatingWithTildeInPath)
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(Palette.subtle)
                    .textSelection(.enabled)
                HStack(spacing: 8) {
                    Button("Preview connection") { makePreview(remove: false) }
                        .buttonStyle(LanternButtonStyle(kind: .secondary))
                    if model.installedProviders.contains(provider) || model.connectionWarnings[provider] != nil || removing {
                        Button("Preview removal") { makePreview(remove: true) }
                            .buttonStyle(LanternButtonStyle(kind: .ghost))
                    }
                }.controlSize(.small).font(.system(size: 11, weight: .medium))
            }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.card, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.border))
            if let preview {
                ArcTabs(tabs: [ArcTab(id: 0, title: "Proposed settings"), ArcTab(id: 1, title: "Current settings")],
                        selection: Binding(get: { showingBefore ? 1 : 0 }, set: { showingBefore = $0 == 1 }))
                ScrollView([.vertical, .horizontal]) {
                    Text(String(decoding: showingBefore ? preview.original ?? Data("(No existing file)".utf8) : preview.updated, as: UTF8.self))
                        .font(.system(size: 10, design: .monospaced)).textSelection(.enabled).padding(12)
                }.frame(height: 180).background(Palette.inset, in: RoundedRectangle(cornerRadius: 12))
                Text("Existing hooks stay in place. A verified backup is created before applying.")
                    .font(.system(size: 11)).foregroundStyle(Palette.subtle)
                Button(removing ? "Apply removal" : "Back up and connect") { apply(preview) }
                    .buttonStyle(LanternButtonStyle(kind: removing ? .danger : .primary))
                    .disabled(model.isDemo)
            }
            if !message.isEmpty { Text(message).font(.system(size: 11)).foregroundStyle(Palette.accentText).textSelection(.enabled) }
            if !error.isEmpty { Text(error).font(.system(size: 11)).foregroundStyle(Palette.warning) }
            Text(provider == .codex
                 ? "After connecting, trust Lantern in Codex CLI /hooks, then start a new desktop session."
                 : "After connecting, restart the Claude Code session in VS Code to load its hooks.")
                .font(.system(size: 11)).foregroundStyle(Palette.subtle).fixedSize(horizontal: false, vertical: true)
            if model.isDemo { Text("Demo: configuration writes are disabled.").font(.system(size: 10)).foregroundStyle(Palette.accentText) }
        }
        .padding(20).frame(width: 480).fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(.white).background(Palette.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Palette.border))
        .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: onHeightChange)
        .preferredColorScheme(.dark)
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
