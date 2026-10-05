import SwiftUI

/// Original lantern silhouette, now green. Both panel sizes and the icon share this drawing.
struct LanternAvatar: View {
    let busy: Bool
    let attention: Bool
    var interactive = true
    @ViewState private var pointer: CGPoint?
    @LanternReducedMotion private var reducedMotion

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reducedMotion || !busy)) { timeline in
                let lift = busy && !reducedMotion ? sin(timeline.date.timeIntervalSinceReferenceDate * 2.6) * side * 0.02 : 0
                ZStack {
                    LanternBody(attention: attention)
                    TrackingEyes(pointer: interactive && !reducedMotion ? pointer.map {
                        CGPoint(x: $0.x - (geometry.size.width - side) / 2,
                                y: $0.y - (geometry.size.height - side) / 2 - lift)
                    } : nil)
                }
                .frame(width: side, height: side)
                .offset(y: lift)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background {
                if interactive && !reducedMotion {
                    CursorReader { pointer = $0 }.allowsHitTesting(false)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(attention ? "Lantern needs your attention" : busy ? "Lantern is watching active agents" : "Lantern is ready")
    }
}

private struct LanternBody: View {
    let attention: Bool

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 100
            context.scaleBy(x: scale, y: scale)
            let green = Color(red: 0.22, green: 0.94, blue: 0.52)
            let darkGreen = Color(red: 0.025, green: 0.22, blue: 0.12)
            var handle = Path()
            handle.addArc(center: CGPoint(x: 50, y: 29), radius: 15,
                          startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            context.stroke(handle, with: .color(green.opacity(0.85)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            let glass = Path(roundedRect: CGRect(x: 21, y: 29, width: 58, height: 53), cornerRadius: 18)
            var glow = context
            glow.addFilter(.shadow(color: (attention ? Palette.amber : green).opacity(attention ? 0.45 : 0.24),
                                   radius: attention ? 10 : 7))
            glow.fill(glass, with: .linearGradient(Gradient(colors: [Color(red: 0.58, green: 1, blue: 0.72), green]),
                startPoint: CGPoint(x: 40, y: 29), endPoint: CGPoint(x: 60, y: 82)))
            context.stroke(glass, with: .color(attention ? Palette.amber : Color.white.opacity(0.65)),
                           lineWidth: attention ? 2 : 1)
            context.fill(Path(roundedRect: CGRect(x: 28, y: 80, width: 44, height: 7), cornerRadius: 3),
                         with: .color(green.opacity(0.8)))
            var smile = Path()
            smile.move(to: CGPoint(x: 45, y: 66))
            smile.addQuadCurve(to: CGPoint(x: 55, y: 66), control: CGPoint(x: 50, y: attention ? 62 : 71))
            context.stroke(smile, with: .color(darkGreen), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            for x: CGFloat in [29, 65] {
                context.fill(Path(ellipseIn: CGRect(x: x, y: 62, width: 6, height: 3)), with: .color(.white.opacity(0.3)))
            }
        }
    }
}
