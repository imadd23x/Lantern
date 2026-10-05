import SwiftUI
import AppKit
import LanternCore

struct SessionRow: View {
    // SwiftUI's named-image lookup does not resolve this WebP; AppKit loads its bundled URL directly.
    private static let claudeCodeIcon: NSImage? = Bundle.module.url(forResource: "ClaudeCode", withExtension: "webp")
        .flatMap { NSImage(contentsOf: $0) }
    private static let codexIcon: NSImage? = Bundle.module.url(forResource: "Codex", withExtension: "png")
        .flatMap { NSImage(contentsOf: $0) }
    let session: AgentSession
    let now: TimeInterval
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11).fill(providerColor.opacity(0.10))
                    if let icon = providerIcon {
                        Image(nsImage: icon)
                            .renderingMode(.original).resizable()
                            .interpolation(session.id.provider == .codex ? .high : .none).scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                    } else {
                        Image(systemName: session.id.provider == .codex ? "terminal" : "asterisk")
                            .font(.system(size: 15, weight: .medium)).foregroundStyle(providerColor)
                    }
                }.frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text(session.project).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                        Text(session.id.provider.title).font(.system(size: 9)).foregroundStyle(Palette.subtle)
                    }
                    Text(session.summary).font(.system(size: 11)).foregroundStyle(Palette.subtle).lineLimit(1)
                }
                Spacer(minLength: 5)
                VStack(alignment: .trailing, spacing: 5) {
                    SessionStatusBadge(phase: session.phase)
                    Text("·\(session.id.id.suffix(6))").font(.system(size: 9, design: .monospaced)).foregroundStyle(Palette.subtle)
                }
                Image(systemName: "arrow.up.right").font(.system(size: 8)).foregroundStyle(Palette.subtle)
            }.padding(11)
        }.buttonStyle(LanternButtonStyle(kind: .row)).help("Open \(session.id.provider.title) · last seen \(Int(max(0, now - session.updatedAt)))s ago")
            .accessibilityLabel("\(session.project), \(session.id.provider.title), \(phaseLabel), \(session.summary). Open agent.")
    }

    private var providerIcon: NSImage? { session.id.provider == .codex ? Self.codexIcon : Self.claudeCodeIcon }
    // The Codex attachment retains transparent margins; compensate within the same 36-point tile.
    private var iconSize: CGFloat { session.id.provider == .codex ? 32 : 26 }
    private var providerColor: Color { session.id.provider == .codex ? .init(red: 0.65, green: 0.82, blue: 1) : .init(red: 0.91, green: 0.61, blue: 0.47) }
    private var phaseLabel: String {
        SessionStatusBadge.label(for: session.phase)
    }
}
