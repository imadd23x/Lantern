import SwiftUI
import LanternCore

struct ProviderFilter: View {
    @Binding var selection: AgentProvider?
    let sessions: [AgentSession]
    private var providers: [AgentProvider?] { [nil, .codex, .claude] }

    var body: some View {
        ArcTabs(tabs: providers.enumerated().map { index, provider in
            ArcTab(id: index, title: provider?.title ?? "All agents",
                   count: sessions.filter { provider == nil || $0.id.provider == provider }.count)
        }, selection: Binding(get: { providers.firstIndex { $0 == selection } ?? 0 },
                              set: { selection = providers[$0] }))
    }
}
