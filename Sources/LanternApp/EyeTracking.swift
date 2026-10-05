import AppKit
import SwiftUI

/// Componentry's distance/3 falloff, generalized to an elliptical travel envelope.
/// Inputs use the eye drawing's coordinates (top-left origin), not global screen coordinates.
enum EyeGaze {
    static func offset(pointer: CGPoint, center: CGPoint, travel: CGSize) -> CGSize {
        guard travel.width > 0, travel.height > 0,
              pointer.x.isFinite, pointer.y.isFinite else { return .zero }
        let dx = (pointer.x - center.x) / travel.width
        let dy = (pointer.y - center.y) / travel.height
        let divisor = max(3, hypot(dx, dy))
        return CGSize(width: dx / divisor * travel.width, height: dy / divisor * travel.height)
    }
}

/// A native adaptation of Componentry's eye tracking. Clipping bounds the pupil even during spring
/// reversal; tracking has no event tap and cannot capture a button press.
struct TrackingEyes: View {
    let pointer: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 100
            ZStack {
                ForEach([39.0, 61.0], id: \.self) { x in
                    let center = CGPoint(x: x, y: 51)
                    let gaze = scale > 0 ? pointer.map {
                        EyeGaze.offset(pointer: CGPoint(x: $0.x / scale, y: $0.y / scale),
                                       center: center, travel: CGSize(width: 3.2, height: 2.1))
                    } ?? .zero : .zero
                    ZStack {
                        Ellipse().fill(Color(red: 0.91, green: 1, blue: 0.94))
                        Ellipse().fill(Color(red: 0.025, green: 0.16, blue: 0.09))
                            .frame(width: 6 * scale, height: 10 * scale)
                            .offset(x: gaze.width * scale, y: gaze.height * scale)
                            .animation(pointer != nil ? .spring(response: 0.26, dampingFraction: 0.98) : nil,
                                       value: gaze)
                    }
                    .frame(width: 14 * scale, height: 17 * scale)
                    .clipShape(Ellipse())
                    .position(x: center.x * scale, y: center.y * scale)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Keep the sampler outside TimelineView so its lifecycle is independent of the animation clock.
/// Static icons/reduced motion omit the reader entirely; ImageRenderer exports only SwiftUI drawing.
struct CursorReader: NSViewRepresentable {
    let onMove: (CGPoint) -> Void

    func makeNSView(context: Context) -> CursorView { CursorView() }

    func updateNSView(_ view: CursorView, context: Context) {
        view.onMove = onMove
        // Initial layout can attach before orderFront. Recheck after that presentation transaction.
        DispatchQueue.main.async { [weak view] in view?.updateSampling() }
    }

    static func dismantleNSView(_ view: CursorView, coordinator: ()) {
        view.stop()
        view.onMove = nil
    }
}

/// Owns one sampler only while attached to a visible window. SwiftUI removes it on collapse/expand;
/// window notifications also suspend it when the panel is hidden or occluded.
@MainActor
final class CursorView: NSView {
    var onMove: ((CGPoint) -> Void)?
    private var timer: Timer?
    private var windowObserver: NSObjectProtocol?
    private var previous: CGPoint?
    var isSampling: Bool { timer?.isValid == true }
    override var isFlipped: Bool { true }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stop()
        guard let window else { return }
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification, object: window, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateSampling() }
        }
        updateSampling()
    }

    func updateSampling() {
        guard onMove != nil, let window, window.isVisible, window.occlusionState.contains(.visible) else {
            timer?.invalidate()
            timer = nil
            previous = nil
            return
        }
        guard timer == nil else { return }
        let sampler = Timer(timeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.sample() }
        }
        timer = sampler
        RunLoop.main.add(sampler, forMode: .common)
    }

    private func sample() {
        guard !isHiddenOrHasHiddenAncestor, !bounds.isEmpty, let window else { return }
        // Reconvert each sample: panel resizing, screen changes and window moves need no stale origin.
        let point = convert(window.convertPoint(fromScreen: NSEvent.mouseLocation), from: nil)
        guard previous.map({ hypot(point.x - $0.x, point.y - $0.y) >= 0.25 }) ?? true else { return }
        previous = point
        onMove?(point)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let windowObserver { NotificationCenter.default.removeObserver(windowObserver) }
        windowObserver = nil
        previous = nil
    }
}
