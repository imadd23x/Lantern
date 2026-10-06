import SwiftUI
import LanternCore

struct CompanionView: View {
    @ObservedObject var model: AppModel
    @ViewState private var filter: AgentProvider?
    @ViewState private var selectedRequest: String?
    @FocusState private var triggerFocused: Bool
    @LanternReducedMotion private var reducedMotion

    private var request: PendingApproval? {
        model.state.approvals.first(where: { $0.id == selectedRequest }) ?? model.state.approvals.first
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header.frame(width: geometry.size.width, height: model.expanded ? 72 : 46)
                details.frame(width: PanelPlacement.expanded.width, height: PanelPlacement.expanded.height - 72)
                    .opacity(model.expanded ? 1 : 0)
                    .animation(reducedMotion ? nil : model.expanded
                               ? .easeOut(duration: 0.24).delay(0.12) : .easeOut(duration: 0.1), value: model.expanded)
                    .allowsHitTesting(model.expanded)
                    .accessibilityHidden(!model.expanded)
            }
            .frame(width: geometry.size.width, alignment: .top)
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .background(Palette.background)
        .clipShape(RoundedRectangle(cornerRadius: model.expanded ? 27 : 23))
        .overlay(RoundedRectangle(cornerRadius: model.expanded ? 27 : 23).stroke(Palette.border, lineWidth: 1))
        .animation(LanternMotion.card(reduced: reducedMotion), value: model.expanded)
        .sheet(isPresented: $model.showConnections) { ConnectionsView(model: model) }
        .onChange(of: model.showConnections) { _, shown in if !shown { model.refreshConnections() } }
        .onChange(of: model.expanded) { _, expanded in
            if !expanded { triggerFocused = !model.presentationIsAutomatic }
        }
        .onExitCommand { if model.expanded { model.setExpanded(false) } else { model.hideCompanion() } }
    }

    private var compactSummary: String {
        model.needsAttention ? "Needs your attention" : model.workingCount > 0 ? "\(model.workingCount) working" : "Lantern is ready"
    }

    // Keep detail text at its final width throughout the morph, without stretching or reflowing it.
    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            if model.isDemo {
                Text("DEMO · Sample sessions, no agent actions")
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(Palette.amber)
                    .padding(.horizontal, 22).padding(.bottom, 10)
            }
            if let error = model.errorMessage {
                Text(error).font(.system(size: 11)).foregroundStyle(.orange)
                    .padding(12).background(Palette.card).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 20)
            }
            ProviderFilter(selection: $filter, sessions: model.sessions)
                .padding(.horizontal, 20).padding(.bottom, 12)
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
    }

    private var header: some View {
        HStack(spacing: model.expanded ? 10 : 6) {
            if model.expanded { WindowGrip().frame(width: 14, height: 38) }
            Button { model.setExpanded(!model.expanded) } label: {
                HStack(spacing: model.expanded ? 12 : 8) {
                    LanternAvatar(busy: model.workingCount > 0, attention: model.needsAttention)
                        .frame(width: model.expanded ? 50 : 36, height: model.expanded ? 54 : 36)
                    Text(model.expanded ? "L A N T E R N" : compactSummary)
                        .font(.system(size: model.expanded ? 10 : 12, weight: .medium, design: .rounded))
                        .foregroundStyle(model.expanded ? Palette.amber : .white).lineLimit(1)
                    Spacer(minLength: 0)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain)
                .accessibilityLabel(model.expanded ? "Collapse Lantern" : "Open Lantern agent sessions")
                .accessibilityValue(model.expanded ? "Expanded" : "Collapsed")
                .help(model.expanded ? "Collapse Lantern" : "Click to open · drag anywhere on the pill to move")
            Button { model.setExpanded(!model.expanded) } label: {
                Image(systemName: "chevron.down").font(.system(size: 10, weight: .semibold))
                    .rotationEffect(.degrees(model.expanded ? 180 : 0))
            }.buttonStyle(LanternButtonStyle(kind: .toolbar)).focused($triggerFocused)
                .accessibilityLabel(model.expanded ? "Collapse Lantern" : "Expand Lantern")
                .accessibilityValue(model.expanded ? "Expanded" : "Collapsed")
                .help(model.expanded ? "Collapse Lantern" : "Expand Lantern")
            if model.expanded {
                Button { model.showConnections = true } label: { Image(systemName: "slider.horizontal.3") }
                    .buttonStyle(LanternButtonStyle(kind: .toolbar)).accessibilityLabel("Open connections").help("Connections")
            }
            Button { model.hideCompanion() } label: { Image(systemName: "xmark").font(.system(size: 10, weight: .medium)) }
                .buttonStyle(LanternButtonStyle(kind: .toolbar)).accessibilityLabel("Hide Lantern and keep listening")
                .help("Hide Lantern · the menu bar brings it back")
        }.padding(.horizontal, model.expanded ? 16 : 10)
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
            Text(filter.map { "No activity from \($0.title) yet." } ?? "Waiting for agent activity.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
            Text(emptyExplanation)
                .font(.system(size: 12)).foregroundStyle(Palette.subtle).multilineTextAlignment(.center).lineSpacing(4)
            Button(needsSetup ? "Review connections" : "Connection details") { model.showConnections = true }
                .buttonStyle(LanternButtonStyle(kind: .secondary))
        }.padding(.horizontal, 34).frame(height: 250)
    }

    private var relevantProviders: [AgentProvider] { filter.map { [$0] } ?? AgentProvider.allCases }
    private var needsSetup: Bool { relevantProviders.contains { !model.installedProviders.contains($0) } }
    private var emptyExplanation: String {
        let installed = relevantProviders.filter { model.installedProviders.contains($0) }.map(\.title)
        if !installed.isEmpty {
            return "\(installed.joined(separator: " and ")) hooks are installed. New activity appears here when an agent starts working."
        }
        return "Review your hooks to receive activity from \(relevantProviders.map(\.title).joined(separator: " and "))."
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
