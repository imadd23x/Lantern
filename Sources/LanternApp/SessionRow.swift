import SwiftUI
import LanternCore

struct SessionRow: View {
    let session: AgentSession
    let now: TimeInterval
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11).fill(providerColor.opacity(0.10))
                    Image(systemName: session.id.provider == .codex ? "terminal" : "asterisk")
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(providerColor)
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
                    Text(phaseLabel).font(.system(size: 9, weight: .medium)).foregroundStyle(phaseColor)
                    Text("·\(session.id.id.suffix(6))").font(.system(size: 9, design: .monospaced)).foregroundStyle(Palette.subtle)
                }
                Image(systemName: "arrow.up.right").font(.system(size: 8)).foregroundStyle(Palette.subtle)
            }.padding(11).background(Palette.card).clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Palette.border.opacity(0.55), lineWidth: 1))
        }.buttonStyle(.plain).help("Open \(session.id.provider.title) · last seen \(Int(max(0, now - session.updatedAt)))s ago")
            .accessibilityLabel("\(session.project), \(session.id.provider.title), \(phaseLabel), \(session.summary). Open agent.")
    }

    private var providerColor: Color { session.id.provider == .codex ? .init(red: 0.65, green: 0.82, blue: 1) : .init(red: 0.91, green: 0.61, blue: 0.47) }
    private var phaseColor: Color {
        switch session.phase {
        case .approval, .attention: Palette.amber
        case .failed: .red
        case .finished: .mint
        default: Palette.subtle
        }
    }
    private var phaseLabel: String {
        switch session.phase {
        case .idle: "Ready"
        case .thinking: "Thinking"
        case .working: "Working"
        case .approval: "Approval"
        case .attention: "Needs you"
        case .finished: "Complete"
        case .failed: "Error"
        case .ended: "Ended"
        }
    }
}
