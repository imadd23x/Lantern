import AppKit
import SwiftUI

/// Display the supplied screenshot unchanged, masking its baked checkerboard in native drawing.
struct CompanionHead: View {
    static let image = Bundle.module.url(forResource: "GreenLanternHead", withExtension: "png")
        .flatMap { NSImage(contentsOf: $0) }
    let image: NSImage
    let attention: Bool

    var body: some View {
        GeometryReader { geometry in
            Image(nsImage: image).resizable().interpolation(.high)
                .frame(width: geometry.size.width * 417 / 214, height: geometry.size.height)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(HeadOutline())
                .overlay(HeadOutline().stroke(attention ? Palette.accent : .clear, lineWidth: 1.2))
                .shadow(color: attention ? Palette.accent.opacity(0.35) : .clear, radius: 4)
        }
        .allowsHitTesting(false)
    }
}

/// Outline coordinates refer to the original 417×214 attachment. Center a 214-point square around
/// its head, retaining the face/hair while excluding the neck connector and all exterior pixels.
private struct HeadOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 211, y: 14))
        path.addCurve(to: CGPoint(x: 283, y: 45), control1: CGPoint(x: 245, y: 14), control2: CGPoint(x: 266, y: 24))
        path.addCurve(to: CGPoint(x: 305, y: 97), control1: CGPoint(x: 298, y: 62), control2: CGPoint(x: 305, y: 80))
        path.addCurve(to: CGPoint(x: 291, y: 143), control1: CGPoint(x: 304, y: 114), control2: CGPoint(x: 301, y: 133))
        path.addCurve(to: CGPoint(x: 287, y: 182), control1: CGPoint(x: 289, y: 153), control2: CGPoint(x: 289, y: 168))
        path.addCurve(to: CGPoint(x: 267, y: 203), control1: CGPoint(x: 287, y: 192), control2: CGPoint(x: 280, y: 199))
        path.addCurve(to: CGPoint(x: 230, y: 209), control1: CGPoint(x: 256, y: 207), control2: CGPoint(x: 244, y: 209))
        path.addLine(to: CGPoint(x: 169, y: 209))
        path.addCurve(to: CGPoint(x: 126, y: 186), control1: CGPoint(x: 150, y: 208), control2: CGPoint(x: 134, y: 198))
        path.addCurve(to: CGPoint(x: 124, y: 148), control1: CGPoint(x: 127, y: 177), control2: CGPoint(x: 125, y: 158))
        path.addCurve(to: CGPoint(x: 109, y: 103), control1: CGPoint(x: 113, y: 137), control2: CGPoint(x: 110, y: 119))
        path.addCurve(to: CGPoint(x: 120, y: 53), control1: CGPoint(x: 105, y: 87), control2: CGPoint(x: 108, y: 70))
        // Follow the steeper left hair edge; the former broad arc included checkerboard above it.
        path.addCurve(to: CGPoint(x: 155, y: 27), control1: CGPoint(x: 125, y: 44), control2: CGPoint(x: 136, y: 34))
        path.addCurve(to: CGPoint(x: 211, y: 14), control1: CGPoint(x: 175, y: 20), control2: CGPoint(x: 190, y: 16))
        path.closeSubpath()
        // The screenshot's outer antialias pixels blend hair with its opaque checkerboard. A tiny
        // source-pixel margin also keeps high-quality image sampling from exposing that light fringe.
        let inset = rect.insetBy(dx: rect.width * 2 / 214, dy: rect.height * 2 / 214)
        return path.applying(CGAffineTransform(a: inset.width / 214, b: 0, c: 0, d: inset.height / 214,
                                               tx: inset.minX - 101.5 * inset.width / 214, ty: inset.minY))
    }
}
