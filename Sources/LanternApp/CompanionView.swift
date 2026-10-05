import SwiftUI
import LanternCore

struct CompanionView: View {
    @ObservedObject var model: AppModel
    @ViewState private var filter: AgentProvider?
    @ViewState private var selectedRequest: String?
    @LanternReducedMotion private var reducedMotion

    private var request: PendingApproval? {
        model.state.approvals.first(where: { $0.id == selectedRequest }) ?? model.state.approvals.first
    }

    var body: some View {
        Group {
            if model.expanded { expanded }
            else { compact }
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .background(Palette.background)
        .clipShape(RoundedRectangle(cornerRadius: model.expanded ? 27 : 23))
        .overlay(RoundedRectangle(cornerRadius: model.expanded ? 27 : 23).stroke(Palette.border, lineWidth: 1))
        .animation(reducedMotion ? nil : .easeOut(duration: 0.18), value: model.expanded)
        .sheet(isPresented: $model.showConnections) { ConnectionsView(model: model) }
    }

    private var compact: some View {
        Button { model.setExpanded(true) } label: {
            HStack(spacing: 9) {
                LanternAvatar(busy: model.workingCount > 0, attention: model.needsAttention).frame(width: 37, height: 37)
                Text(model.needsAttention ? "Needs your attention" : model.workingCount > 0 ? "\(model.workingCount) working" : "Lantern is ready")
                    .font(.system(size: 12, weight: .medium))
                Spacer(minLength: 0)
                if model.needsAttention { Circle().fill(Palette.amber).frame(width: 6, height: 6) }
                else { Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundStyle(Palette.subtle) }
            }.padding(.horizontal, 12).frame(width: 246, height: 46)
        }.buttonStyle(.plain).accessibilityLabel("Open Lantern agent sessions")
    }

    private var expanded: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if model.isDemo {
                Text("DEMO · Sample sessions, no agent actions")
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(Palette.amber)
                    .padding(.horizontal, 22).padding(.bottom, 10)
            }
            if let error = model.errorMessage {
                Text(error).font(.system(size: 11)).foregroundStyle(.orange)
                    .padding(12).background(Palette.card).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 20)
            }
            HStack {
                ProviderFilter(selection: $filter, sessions: model.sessions)
                Spacer(minLength: 0)
            }.padding(.horizontal, 20).padding(.bottom, 12)
            ScrollView {
                LazyVStack(spacing: 7) {
                    let sessions = model.sessions.filter { filter == nil || $0.id.provider == filter }
                    if sessions.isEmpty { emptyState }
                    ForEach(sessions) { session in SessionRow(session: session, now: model.now) { model.openAgent(session) } }
                }.padding(.horizontal, 20)
            }
            .frame(maxHeight: request == nil ? .infinity : 116)
            if let request {
                approvalQueue.padding(.horizontal, 20).padding(.top, 12)
                ApprovalCard(request: request, now: model.now, decide: { decision in model.decide(request.id, decision) },
                             answerInAgent: {
                    let session = model.state.sessions[request.event.key]
                    model.decide(request.id, .delegate)
                    if let session { model.openAgent(session) }
                }).id(request.id).padding(.horizontal, 20).padding(.top, 9)
            }
            Spacer(minLength: 10)
            footer
        }
        .frame(width: 460, height: 584)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            LanternAvatar(busy: model.workingCount > 0, attention: model.needsAttention).frame(width: 72, height: 80)
            VStack(alignment: .leading, spacing: 6) {
                Text("L A N T E R N").font(.system(size: 9, weight: .semibold)).foregroundStyle(Palette.amber)
                Text(request != nil ? "A little attention.\nThen back to flow." : "Your agents,\nin view.")
                    .font(.system(size: 21, weight: .semibold, design: .rounded)).lineSpacing(1)
            }
            Spacer()
            VStack(spacing: 14) {
                Button { model.setExpanded(false) } label: { Image(systemName: "chevron.up") }
                    .help("Collapse Lantern").accessibilityLabel("Collapse Lantern")
                Button { model.showConnections = true } label: { Image(systemName: "slider.horizontal.3") }
                    .help("Connections").accessibilityLabel("Open connections")
            }.font(.system(size: 12)).buttonStyle(LanternButtonStyle(kind: .toolbar))
        }.padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 12)
    }

    private var approvalQueue: some View {
        HStack {
            Text("NEEDS YOU").font(.system(size: 9, weight: .semibold)).tracking(1.3).foregroundStyle(Palette.amber)
            Spacer()
            if model.state.approvals.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Array(model.state.approvals.enumerated()), id: \.element.id) { index, approval in
                            Button("\(index + 1)") { selectedRequest = approval.id }
                                .buttonStyle(.plain).font(.system(size: 10, weight: .semibold))
                                .frame(width: 22, height: 22)
                                .background(request?.id == approval.id ? Palette.amber.opacity(0.18) : Palette.card)
                                .clipShape(Circle()).accessibilityLabel("Show queued request \(index + 1) from \(approval.event.provider.title)")
                        }
                    }
                }.frame(maxWidth: 180)
            }
            Text("\(model.state.approvals.count) queued").font(.system(size: 10)).foregroundStyle(Palette.subtle)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkle").font(.system(size: 28)).foregroundStyle(Palette.amber.opacity(0.7))
            Text("A quiet place for busy agents.").font(.system(size: 15, weight: .medium, design: .rounded))
            Text("Connect Codex and Claude Code to see their progress and answer permission requests here.")
                .font(.system(size: 12)).foregroundStyle(Palette.subtle).multilineTextAlignment(.center).lineSpacing(4)
            Button("Set up connections") { model.showConnections = true }.buttonStyle(LanternButtonStyle(kind: .secondary))
        }.padding(.horizontal, 34).frame(height: 250)
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Circle().fill(model.isListening ? Color.mint : Color.orange).frame(width: 5, height: 5)
            Text(model.isListening ? "Local connection ready" : "Connection unavailable").font(.system(size: 10))
            Spacer()
            Button { model.quiet.toggle() } label: { Image(systemName: model.quiet ? "bell.slash" : "bell") }
                .buttonStyle(.plain).help(model.quiet ? "Enable attention sounds" : "Quiet mode")
                .accessibilityLabel(model.quiet ? "Enable attention sounds" : "Mute attention sounds")
            Text("Private by default").font(.system(size: 10))
        }.foregroundStyle(Palette.subtle).padding(.horizontal, 22).padding(.vertical, 15)
            .background(Color.white.opacity(0.025))
    }
}
