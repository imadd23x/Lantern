import SwiftUI
import LanternCore

struct UsageWindowView: View {
    let title: String
    let window: ReceivedUsageWindow?
    let now: TimeInterval

    private var freshness: UsageFreshness? { window?.status(now: now) }
    private var value: String {
        guard let window else { return "Unavailable" }
        switch freshness {
        case .fresh: return String(format: "%.0f%%", window.value.usedPercentage)
        case .stale: return String(format: "%.0f%% · stale", window.value.usedPercentage)
        default: return "Awaiting refresh"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.system(size: 13, weight: .medium))
                Spacer()
                Text(value).font(.system(size: 12, design: .monospaced)).foregroundStyle(Palette.subtle)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    if let window, freshness == .fresh || freshness == .stale {
                        Capsule().fill(Palette.accent.opacity(freshness == .fresh ? 1 : 0.35))
                            .frame(width: geometry.size.width * window.value.usedPercentage / 100)
                    }
                }
            }.frame(height: 7)
            if let reset = window?.value.resetsAt, freshness == .fresh || freshness == .stale {
                HStack(spacing: 4) {
                    Text("Resets")
                    Text(Date(timeIntervalSince1970: reset), style: .relative)
                }.font(.system(size: 11)).foregroundStyle(Palette.subtle)
            }
        }.accessibilityElement(children: .ignore).accessibilityLabel(title + " Claude usage")
            .accessibilityValue(value)
    }
}

struct UsageIndicator: View {
    @ObservedObject var model: AppModel
    private var value: String {
        guard let window = model.claudeUsage.fiveHour, window.status(now: model.now) == .fresh else { return "—" }
        return String(format: "%.0f%%", window.value.usedPercentage)
    }
    var body: some View {
        Button { model.onSettingsRequest?() } label: {
            Text("Claude " + value).font(.system(size: 10, design: .monospaced))
        }.buttonStyle(.plain).foregroundStyle(value == "—" ? Palette.subtle : Palette.accent)
            .accessibilityLabel("Claude five-hour usage")
            .accessibilityValue(value == "—" ? "Unavailable or awaiting fresh data" : value + " used")
            .help("Five-hour Claude usage · see Settings → Usage for details. A dash means unavailable or awaiting fresh data.")
    }
}
