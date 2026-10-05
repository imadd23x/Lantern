import SwiftUI
import LanternCore

/// Original geometric lantern: a warm glass face suspended beneath an arched handle.
struct LanternAvatar: View {
    let busy: Bool
    let attention: Bool
    @Environment(\.accessibilityReduceMotion) private var reducedMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reducedMotion || !busy)) { timeline in
            let time = reducedMotion || !busy ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let scale = min(size.width, size.height) / 100
                context.scaleBy(x: scale, y: scale)
                let lift = busy ? sin(time * 2.6) * 2 : 0
                context.translateBy(x: 0, y: lift)
                let color: Color = attention ? .init(red: 1, green: 0.68, blue: 0.34) : .init(red: 1, green: 0.78, blue: 0.42)
                var handle = Path()
                handle.addArc(center: CGPoint(x: 50, y: 29), radius: 15,
                              startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                context.stroke(handle, with: .color(color.opacity(0.8)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                let glass = Path(roundedRect: CGRect(x: 21, y: 29, width: 58, height: 53), cornerRadius: 18)
                context.addFilter(.shadow(color: color.opacity(0.25), radius: 8))
                context.fill(glass, with: .linearGradient(Gradient(colors: [color, color.opacity(0.68)]),
                    startPoint: CGPoint(x: 50, y: 29), endPoint: CGPoint(x: 50, y: 82)))
                context.stroke(glass, with: .color(Color.white.opacity(0.45)), lineWidth: 1)
                context.fill(Path(roundedRect: CGRect(x: 28, y: 80, width: 44, height: 7), cornerRadius: 3), with: .color(color.opacity(0.75)))
                let gaze: CGFloat = busy ? CGFloat(sin(time * 0.7)) * 1.4 : 0
                let blink: CGFloat = busy && Int(time * 4) % 23 == 0 ? 2 : 10
                for x: CGFloat in [39, 61] {
                    context.fill(Path(roundedRect: CGRect(x: x - 3 + gaze, y: 51 + (10 - blink) / 2,
                                                          width: 6, height: blink), cornerRadius: 3),
                                 with: .color(.init(red: 0.24, green: 0.17, blue: 0.12)))
                }
                var smile = Path()
                smile.move(to: CGPoint(x: 45, y: 66))
                smile.addQuadCurve(to: CGPoint(x: 55, y: 66), control: CGPoint(x: 50, y: attention ? 62 : 71))
                context.stroke(smile, with: .color(.init(red: 0.32, green: 0.2, blue: 0.13)),
                               style: StrokeStyle(lineWidth: 2, lineCap: .round))
                context.fill(Path(ellipseIn: CGRect(x: 29, y: 62, width: 6, height: 3)), with: .color(.white.opacity(0.25)))
                context.fill(Path(ellipseIn: CGRect(x: 65, y: 62, width: 6, height: 3)), with: .color(.white.opacity(0.25)))
            }
        }
        .accessibilityLabel(attention ? "Lantern needs your attention" : busy ? "Lantern is watching active agents" : "Lantern is ready")
    }
}
