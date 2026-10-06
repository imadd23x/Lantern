import AppKit
import Combine
import LanternCore
import LanternTransport

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var state = SessionState()
    @Published private(set) var expanded = false
    @Published private(set) var companionHidden = false
    @Published private(set) var presentationIsAutomatic = false
    @Published var showConnections = false {
        didSet { if showConnections { presentationIsAutomatic = false } }
    }
    @Published var errorMessage: String?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published private(set) var installedProviders: Set<AgentProvider> = []
    @Published private(set) var connectionWarnings: [AgentProvider: String] = [:]
    @Published var quiet = false
    @Published private(set) var now = Date().timeIntervalSince1970
    let isDemo: Bool
    private let server: HookServer
    private var timer: Timer?
    private var disconnected: Set<String> = []
    private let clock: () -> TimeInterval
    private let navigator: AgentNavigator
    private let attentionSound = Bundle.module.url(forResource: "A-Train", withExtension: "mp3")
        .flatMap { NSSound(contentsOf: $0, byReference: false) }
    var onPresentationChange: (() -> Void)?
    var onApprovalDecision: ((HookDecision) -> Void)?

    init(demo: Bool = false, directory: URL = RuntimeDirectory.current,
         clock: @escaping () -> TimeInterval = { Date().timeIntervalSince1970 },
         navigator: AgentNavigator = .live) {
        self.clock = clock; now = clock()
        self.navigator = navigator
        isDemo = demo; server = HookServer(directory: directory)
    }

    var sessions: [AgentSession] {
        state.sessions.values.sorted {
            if ($0.phase == .approval) != ($1.phase == .approval) { return $0.phase == .approval }
            return $0.updatedAt > $1.updatedAt
        }
    }
    var workingCount: Int { sessions.filter { [.thinking, .working].contains($0.phase) }.count }
    var needsAttention: Bool { !state.approvals.isEmpty || sessions.contains { [.attention, .failed].contains($0.phase) } }
    var relayPath: String { Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/lantern-hook").path }
    var socketPath: String { server.socketPath }
    var isListening: Bool { connectionStatus == .connected }

    func configurationURL(for provider: AgentProvider) -> URL {
        let env = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser
        let directory = provider == .codex
            ? env["CODEX_HOME"] ?? home.appendingPathComponent(".codex").path
            : env["CLAUDE_CONFIG_DIR"] ?? home.appendingPathComponent(".claude").path
        return URL(fileURLWithPath: directory).appendingPathComponent(provider == .codex ? "hooks.json" : "settings.json")
    }

    func refreshConnections() {
        var installed: Set<AgentProvider> = []
        var warnings: [AgentProvider: String] = [:]
        for provider in AgentProvider.allCases {
            do {
                switch try HookConfiguration.installation(original: ConfigurationTransaction.read(configurationURL(for: provider)),
                                                          provider: provider, relayPath: relayPath) {
                case .installed: installed.insert(provider)
                case .incomplete: warnings[provider] = "Hooks need review"
                case .absent: break
                }
            } catch { warnings[provider] = "Settings could not be read" }
        }
        installedProviders = installed; connectionWarnings = warnings
    }

    func start() {
        guard !isListening else { return }
        connectionStatus = .connecting
        refreshConnections()
        do {
            try server.start(onEvent: { [weak self] event, id in
                Task { @MainActor [weak self] in self?.receive(event, id: id) }
            }, onDisconnect: { [weak self] id in
                Task { @MainActor [weak self] in self?.connectionClosed(id) }
            })
            errorMessage = nil
            connectionStatus = .connected
        } catch {
            errorMessage = error.localizedDescription
            connectionStatus = .failed
        }
        if isDemo { loadDemo() }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    func stop() { timer?.invalidate(); timer = nil; server.stop(); connectionStatus = .disconnected }

    func setExpanded(_ value: Bool) {
        presentationIsAutomatic = false
        if value && !expanded { refreshConnections() }
        expanded = value; onPresentationChange?()
    }

    func hideCompanion() {
        presentationIsAutomatic = false
        showConnections = false; expanded = false; companionHidden = true; onPresentationChange?()
    }

    func showCompanion(expanded: Bool = false) {
        companionHidden = false; setExpanded(expanded)
    }

    var visibilityMenuTitle: String { companionHidden ? "Show Lantern" : "Hide Lantern" }
    var allowsKeyboardFocus: Bool { showConnections || !presentationIsAutomatic }

    func toggleCompanionVisibility() {
        if companionHidden { showCompanion() } else { hideCompanion() }
    }

    func decide(_ id: String, _ decision: HookDecision) {
        let hadApprovals = !state.approvals.isEmpty
        let request = state.resolve(id, now: clock())
        server.respond(to: id, with: request == nil ? .delegate : decision)
        _ = restorePresentationIfQueueDrained(hadApprovals: hadApprovals)
        onApprovalDecision?(decision)
    }

    @discardableResult
    func openAgent(_ session: AgentSession) -> Bool {
        let failure = navigator.open(session)
        if let failure { errorMessage = failure; return false }
        errorMessage = nil
        return true
    }

    func answerInAgent(_ id: String) {
        guard let request = state.approvals.first(where: { $0.id == id }),
              let session = state.sessions[request.event.key] else { return }
        // A navigation failure must leave the selected request actionable in Lantern.
        guard openAgent(session) else { return }
        decide(id, .delegate)
    }

    private func receive(_ event: AgentEvent, id: String) {
        if disconnected.remove(id) != nil { return }
        let hadApprovals = !state.approvals.isEmpty
        let cleared = state.apply(event, requestID: event.kind == .approval ? id : nil, now: now)
        for request in cleared { server.respond(to: request, with: .delegate) }
        let restored = restorePresentationIfQueueDrained(hadApprovals: hadApprovals)
        if [.approval, .attention, .failed].contains(event.kind) {
            if !companionHidden && !expanded && !restored {
                presentationIsAutomatic = true
                refreshConnections()
                expanded = true; onPresentationChange?()
            }
            if !quiet { (attentionSound ?? NSSound(named: "Tink"))?.play() }
        }
    }

    private func connectionClosed(_ id: String) {
        let hadApprovals = !state.approvals.isEmpty
        // Callback Tasks can reach the main actor in either order. Remember early disconnects.
        if state.resolve(id, now: now) == nil {
            disconnected.insert(id)
            if disconnected.count > 256 { disconnected.removeAll(keepingCapacity: true) }
        }
        _ = restorePresentationIfQueueDrained(hadApprovals: hadApprovals)
    }

    private func tick() {
        now = clock()
        let hadApprovals = !state.approvals.isEmpty
        for id in state.expire(now: now) { server.respond(to: id, with: .delegate) }
        _ = restorePresentationIfQueueDrained(hadApprovals: hadApprovals)
    }

    private func restorePresentationIfQueueDrained(hadApprovals: Bool) -> Bool {
        guard hadApprovals, state.approvals.isEmpty, presentationIsAutomatic,
              expanded, !showConnections else { return false }
        // Retain automatic focus policy through the closing animation and compact presentation.
        // A later explicit user presentation action opts back into normal keyboard interaction.
        expanded = false; onPresentationChange?()
        return true
    }

    private func loadDemo() {
        state.apply(AgentEvent(provider: .codex, sessionID: "demo-codex", kind: .working,
            cwd: "/Projects/Lantern", summary: "Checking the session reducer"), now: now - 5)
        state.apply(AgentEvent(provider: .claude, sessionID: "demo-claude", kind: .approval,
            cwd: "/Projects/Workspace", summary: "Bash",
            detail: "{\n  \"command\": \"npm run test -- --watch=false\"\n}",
            reason: "Run the project test suite"), requestID: "demo-approval", now: now)
    }
}
