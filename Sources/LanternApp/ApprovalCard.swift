import SwiftUI
import LanternCore

struct ApprovalCard: View {
    let request: PendingApproval
    let now: TimeInterval
    let decide: (HookDecision) -> Void
    let answerInAgent: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "hand.raised").foregroundStyle(Palette.amber)
                Text(request.event.summary).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                Spacer()
                Text("\(max(0, Int(request.expiresAt - now)))s").font(.system(size: 10, design: .monospaced)).foregroundStyle(Palette.subtle)
            }
            Text("\(request.event.provider.title) · session \(request.event.sessionID.suffix(8))")
                .font(.system(size: 10)).foregroundStyle(Palette.subtle)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if !request.event.cwd.isEmpty { Text(request.event.cwd).foregroundStyle(Palette.subtle) }
                    if !request.event.reason.isEmpty { Text(request.event.reason).foregroundStyle(.white.opacity(0.85)) }
                    Text(request.event.detail.isEmpty ? "No tool input was provided. Review this request in the agent." : request.event.detail)
                        .foregroundStyle(Palette.amber.opacity(0.9))
                }.font(.system(size: 11, design: .monospaced)).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(11)
            }.frame(height: 122).background(.black.opacity(0.22)).clipShape(RoundedRectangle(cornerRadius: 10))
            HStack(spacing: 8) {
                Button { decide(.allow) } label: { Label("Allow once", systemImage: "checkmark").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).tint(Palette.amber).foregroundStyle(.black)
                    .disabled(request.event.detail.isEmpty || now >= request.expiresAt)
                Button("Deny") { decide(.deny) }.buttonStyle(.bordered)
                    .disabled(now >= request.expiresAt)
            }.controlSize(.regular).font(.system(size: 12, weight: .medium))
            Button("Answer in agent ↗", action: answerInAgent).buttonStyle(.plain)
                .font(.system(size: 10)).foregroundStyle(Palette.subtle)
        }.padding(14).background(Palette.amber.opacity(0.045)).clipShape(RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(Palette.amber.opacity(0.17), lineWidth: 1))
    }
}
