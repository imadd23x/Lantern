import AppKit
import SwiftUI

/// Give the original mouse-down to AppKit's window drag; buttons elsewhere keep normal click semantics.
struct WindowGrip: NSViewRepresentable {
    func makeNSView(context: Context) -> GripView { GripView() }
    func updateNSView(_ nsView: GripView, context: Context) {}
}

final class GripView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        toolTip = "Drag to move Lantern"
        setAccessibilityElement(true)
        setAccessibilityRole(.image)
        setAccessibilityLabel("Drag to move Lantern")
    }
    required init?(coder: NSCoder) { nil }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .openHand) }
    override func mouseDown(with event: NSEvent) { window?.performDrag(with: event) }
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.withAlphaComponent(0.35).setFill()
        for x in [bounds.midX - 2.5, bounds.midX + 2.5] {
            for y in [bounds.midY - 5, bounds.midY, bounds.midY + 5] {
                NSBezierPath(ovalIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)).fill()
            }
        }
    }
}
