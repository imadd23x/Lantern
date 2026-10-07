import SwiftUI
import LanternCore

struct CompanionView: View {
    @ObservedObject var model: AppModel
    @FocusState private var triggerFocused: Bool
    @LanternReducedMotion private var reducedMotion

    private var request: PendingApproval? {
        model.selectedApproval
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header.frame(width: geometry.size.width, height: model.expanded ? 72 : 46)
                details.frame(width: PanelPlacement.expanded.width, height: max(0, geometry.size.height - PanelLayout.headerHeight))
                    .opacity(model.expanded ? 1 : 0)
                    .animation(reducedMotion ? nil : model.expanded
                               ? .easeOut(duration: LanternMotion.detailsRevealDuration).delay(LanternMotion.detailsRevealDelay) : .easeOut(duration: 0.1), value: model.expanded)
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
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(Palette.accent)
                    .padding(.horizontal, 22).padding(.bottom, 10)
            }
            if let error = model.errorMessage {
                Text(error).font(.system(size: 11)).foregroundStyle(Palette.warning).lineLimit(2)
                    .padding(12).background(Palette.card).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 20)
            }
            ProviderFilter(selection: $model.providerFilter, sessions: model.sessions)
                .padding(.horizontal, 20).padding(.bottom, 12)
            ScrollView {
                LazyVStack(spacing: 7) {
                    let sessions = model.visibleSessions
                    if sessions.isEmpty {
                        if request == nil { emptyState }
                        else { Text("No sessions in this tab").font(.system(size: 12)).foregroundStyle(Palette.subtle).frame(height: 48) }
                    }
                    ForEach(sessions) { session in SessionRow(session: session, now: model.now) { model.openAgent(session) }.frame(height: PanelLayout.rowHeight) }
                }.padding(.horizontal, 20)
            }
            .frame(maxHeight: request == nil ? .infinity : 116)
            .layoutPriority(-1)
            if let request {
                approvalQueue.padding(.horizontal, 20).padding(.top, 12)
                ApprovalCard(request: request, now: model.now, decide: { decision in model.decide(request.id, decision) },
                             answerInAgent: { model.answerInAgent(request.id) },
                             allowShortcut: model.desktopPreferences.shortcutsEnabled && model.allowsGlobalApproval
                                ? model.desktopPreferences.bindings[.allowOnce].flatMap { $0.enabled ? $0.label : nil } : nil)
                    .id(request.id)
                    .onAppear { model.setDisplayedApproval(request.id, visible: true) }
                    .onDisappear { model.setDisplayedApproval(request.id, visible: false) }
                    .frame(height: PanelLayout.approvalHeight)
                    .padding(.horizontal, 20).padding(.top, 9)
            }
            Color.clear.frame(height: 12)
            footer.frame(height: 44)
        }
    }

    private var header: some View {
        HStack(spacing: model.expanded ? 10 : 6) {
            Button { model.setExpanded(!model.expanded) } label: {
                HStack(spacing: model.expanded ? 12 : 8) {
                    LanternAvatar(busy: model.workingCount > 0, attention: model.needsAttention)
                        .frame(width: model.expanded ? 50 : 36, height: model.expanded ? 54 : 36)
                    Text(model.expanded ? "L A N T E R N" : compactSummary)
                        .font(.system(size: model.expanded ? 10 : 12, weight: .medium, design: .rounded))
                        .foregroundStyle(model.expanded ? Palette.accent : .white).lineLimit(1)
                    Spacer(minLength: 0)
                }.contentShape(Rectangle())
            }.buttonStyle(LanternButtonStyle(kind: .switchRow))
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
                Button { model.isSettingsMenuOpen.toggle() } label: { Image(systemName: "gearshape") }
                    .buttonStyle(LanternButtonStyle(kind: .menuTrigger))
                    .accessibilityLabel("Open Lantern settings menu").help("Settings")
                    .popover(isPresented: $model.isSettingsMenuOpen, arrowEdge: .bottom) { SettingsMenu(model: model) }
            }
            Button { model.hideCompanion() } label: { Image(systemName: "xmark").font(.system(size: 10, weight: .medium)) }
                .buttonStyle(LanternButtonStyle(kind: .toolbar)).accessibilityLabel("Hide Lantern and keep listening")
                .help("Hide Lantern · the menu bar brings it back")
        }
        .padding(.leading, model.expanded ? 20 : 10)
        .padding(.trailing, model.expanded ? 16 : 10)

    }

    private var approvalQueue: some View {
        HStack {
            Text("NEEDS YOU").font(.system(size: 9, weight: .semibold)).tracking(1.3).foregroundStyle(Palette.accent)
            Spacer()
            if model.state.approvals.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Array(model.state.approvals.enumerated()), id: \.element.id) { index, approval in
                            Button("\(index + 1)") { model.selectedRequestID = approval.id }
                                .buttonStyle(LanternButtonStyle(kind: .tab)).font(.system(size: 10, weight: .semibold))
                                .frame(width: 22, height: 22)
                                .background(request?.id == approval.id ? Palette.accent.opacity(0.18) : Palette.card)
                                .clipShape(Circle()).accessibilityLabel("Show queued request \(index + 1) from \(approval.event.provider.title)")
                        }
                    }
                }.frame(maxWidth: 180)
            }
            Text("\(model.state.approvals.count) queued").font(.system(size: 10)).foregroundStyle(Palette.subtle)
        }
    }

    private var emptyState: some View {
        AgentEmptyState(title: model.providerFilter.map { "No \($0.title) sessions yet" } ?? "Ready for your agents",
                        explanation: emptyExplanation,
                        actionTitle: needsSetup ? "Connect agents" : "Agent connections") { model.showConnections = true }
    }

    private var relevantProviders: [AgentProvider] { model.providerFilter.map { [$0] } ?? AgentProvider.allCases }
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
            Circle().fill(model.connectionStatus.indicatorColor).frame(width: 5, height: 5)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Agent connection")
                .accessibilityValue(model.connectionStatus.title)
                .help(model.connectionStatus.title)
            Spacer()
            Button { model.quiet.toggle() } label: { Image(systemName: model.quiet ? "bell.slash" : "bell") }
                .buttonStyle(LanternButtonStyle(kind: .toolbar))
                .help(model.quiet ? "Enable attention sounds" : "Mute attention sounds")
                .accessibilityLabel(model.quiet ? "Enable attention sounds" : "Mute attention sounds")
                .accessibilityValue(model.quiet ? "Muted" : "Enabled")
        }.foregroundStyle(Palette.subtle).padding(.horizontal, 22).padding(.vertical, 8)
            .background(Color.white.opacity(0.025))
    }
}
