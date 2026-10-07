import SwiftUI
import LanternCore

struct ApprovalCard: View {
    let request: PendingApproval
    let now: TimeInterval
    let decide: (HookDecision) -> Void
    let answerInAgent: () -> Void
    var allowShortcut: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "hand.raised").foregroundStyle(Palette.accent)
                Text(request.event.summary).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                Spacer()
                Label("\(max(0, Int(request.expiresAt - now)))s", systemImage: "clock")
                    .font(.system(size: 10, design: .monospaced)).monospacedDigit()
                    .foregroundStyle(Palette.subtle).padding(.horizontal, 7).padding(.vertical, 4)
                    .background(Color.white.opacity(0.04), in: Capsule())
                    .accessibilityLabel("\(max(0, Int(request.expiresAt - now))) seconds remaining")
            }
            Text("\(request.event.provider.title) · session \(request.event.sessionID.suffix(8))")
                .font(.system(size: 10)).foregroundStyle(Palette.subtle)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if !request.event.cwd.isEmpty { Text(request.event.cwd).foregroundStyle(Palette.subtle) }
                    if !request.event.reason.isEmpty { Text(request.event.reason).foregroundStyle(.white.opacity(0.85)) }
                    Text(request.event.detail.isEmpty ? "No tool input was provided. Review this request in the agent." : request.event.detail)
                        .foregroundStyle(Palette.accent)
                }.font(.system(size: 11, design: .monospaced)).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(11)
            }.frame(height: 122).background(.black.opacity(0.22)).clipShape(RoundedRectangle(cornerRadius: 10))
            HStack(spacing: 8) {
                Button { decide(.allow) } label: {
                    HStack {
                        Label("Allow once", systemImage: "checkmark")
                        if let allowShortcut { Text(allowShortcut).font(.system(size: 10, design: .monospaced)).opacity(0.7) }
                    }.frame(maxWidth: .infinity)
                }
                    .buttonStyle(LanternButtonStyle(kind: .primary))
                    .disabled(request.event.detail.isEmpty || now >= request.expiresAt)
                Button("Deny") { decide(.deny) }.buttonStyle(LanternButtonStyle(kind: .secondary))
                    .disabled(now >= request.expiresAt)
            }.controlSize(.regular).font(.system(size: 12, weight: .medium))
            Button("Answer in agent ↗", action: answerInAgent).buttonStyle(.plain)
                .font(.system(size: 10)).foregroundStyle(Palette.subtle)
        }.padding(14).background(Palette.accent.opacity(0.045)).clipShape(RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(Palette.accent.opacity(0.17), lineWidth: 1))
    }
}
