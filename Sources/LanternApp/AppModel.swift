import AppKit
import Combine
import LanternCore
import LanternTransport

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var state = SessionState()
    @Published var expanded = true
    @Published var showConnections = false
    @Published var errorMessage: String?
    @Published private(set) var isListening = false
    @Published var quiet = false
    @Published private(set) var now = Date().timeIntervalSince1970
    let isDemo: Bool
    private let server: HookServer
    private var timer: Timer?
    private var disconnected: Set<String> = []
    var onPresentationChange: (() -> Void)?

    init(demo: Bool = false, directory: URL = RuntimeDirectory.current) {
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

    func start() {
        do {
            try server.start(onEvent: { [weak self] event, id in
                Task { @MainActor [weak self] in self?.receive(event, id: id) }
            }, onDisconnect: { [weak self] id in
                Task { @MainActor [weak self] in self?.connectionClosed(id) }
            })
            isListening = true
        } catch { errorMessage = error.localizedDescription }
        if isDemo { loadDemo() }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    func stop() { timer?.invalidate(); timer = nil; server.stop(); isListening = false }

    func setExpanded(_ value: Bool) {
        expanded = value; onPresentationChange?()
    }

    func decide(_ id: String, _ decision: HookDecision) {
        guard state.resolve(id, now: Date().timeIntervalSince1970) != nil else {
            server.respond(to: id, with: .delegate); return
        }
        server.respond(to: id, with: decision)
    }

    func openAgent(_ session: AgentSession) {
        if session.id.provider == .codex {
            // Codex deep links are escaped by URLComponents; no shell or arbitrary scheme from hook data.
            var link = URLComponents()
            link.scheme = "codex"; link.host = "threads"; link.path = "/" + session.id.id
            if let url = link.url { NSWorkspace.shared.open(url) }
        } else if !session.cwd.isEmpty {
            // VS Code's folder deep link focuses/opens the workspace; no terminal automation permissions.
            var link = URLComponents()
            link.scheme = "vscode"; link.host = "file"; link.path = session.cwd
            if let url = link.url { NSWorkspace.shared.open(url) }
        } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.VSCode") {
            NSWorkspace.shared.openApplication(at: url, configuration: .init())
        }
    }

    private func receive(_ event: AgentEvent, id: String) {
        if disconnected.remove(id) != nil { return }
        let cleared = state.apply(event, requestID: event.kind == .approval ? id : nil, now: now)
        for request in cleared { server.respond(to: request, with: .delegate) }
        if [.approval, .attention, .failed].contains(event.kind) {
            setExpanded(true)
            if !quiet { NSSound(named: "Tink")?.play() }
        }
    }

    private func connectionClosed(_ id: String) {
        // Callback Tasks can reach the main actor in either order. Remember early disconnects.
        if state.resolve(id, now: now) == nil {
            disconnected.insert(id)
            if disconnected.count > 256 { disconnected.removeAll(keepingCapacity: true) }
        }
    }

    private func tick() {
        now = Date().timeIntervalSince1970
        for id in state.expire(now: now) { server.respond(to: id, with: .delegate) }
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
