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
}
