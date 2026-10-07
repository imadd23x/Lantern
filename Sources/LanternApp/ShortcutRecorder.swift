import AppKit
import SwiftUI

struct ShortcutRecorder: NSViewRepresentable {
    let action: ShortcutAction
    @ObservedObject var controller: ShortcutController

    func makeNSView(context: Context) -> ShortcutInput { ShortcutInput() }
    func updateNSView(_ view: ShortcutInput, context: Context) {
        view.binding = controller.preferences.bindings[action]
        view.capturing = controller.recording == action
        view.onBegin = { controller.recording = action }
        view.onCancel = { controller.recording = nil }
        view.onCommit = { controller.update($0, for: action) }
        view.setAccessibilityLabel("Shortcut for " + action.title)
        view.setAccessibilityValue(view.capturing ? "Recording" : view.binding?.label ?? "Unassigned")
        view.needsDisplay = true
    }
}

final class ShortcutInput: NSView {
    var binding: ShortcutBinding?
    var capturing = false { didSet { if !capturing { pending = nil; message = nil } } }
    var onBegin: (() -> Void)?
    var onCancel: (() -> Void)?
    var onCommit: ((ShortcutBinding) -> Bool)?
    private var pending: ShortcutBinding?
    private var message: String?
    override var acceptsFirstResponder: Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        setAccessibilityElement(true); setAccessibilityRole(.button)
        toolTip = "Click and press a modified key. Escape cancels."
    }
    required init?(coder: NSCoder) { nil }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    override func accessibilityPerformPress() -> Bool { begin(); return true }
    override func mouseDown(with event: NSEvent) { begin() }
    private func begin() { capturing = true; onBegin?(); window?.makeFirstResponder(self); needsDisplay = true }
    override func resignFirstResponder() -> Bool { onCancel?(); return super.resignFirstResponder() }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard capturing, window?.firstResponder === self else { return false }
        keyDown(with: event); return true
    }
    override func keyDown(with event: NSEvent) {
        guard capturing else {
            if [36, 49].contains(event.keyCode) && event.modifierFlags.intersection([.command, .control, .option]).isEmpty { begin() }
            else { super.keyDown(with: event) }
            return
        }
        if event.keyCode == 53 { onCancel?(); window?.makeFirstResponder(nil); return }
        var modifiers: ShortcutModifiers = []
        if event.modifierFlags.contains(.control) { modifiers.insert(.control) }
        if event.modifierFlags.contains(.option) { modifiers.insert(.option) }
        if event.modifierFlags.contains(.command) { modifiers.insert(.command) }
        if event.modifierFlags.contains(.shift) { modifiers.insert(.shift) }
        let names: [UInt16: String] = [36: "Return", 48: "Tab", 49: "Space", 51: "Delete", 117: "Delete",
                                     123: "←", 124: "→", 125: "↓", 126: "↑"]
        let functionKeys: [UInt16] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79, 80, 90]
        let function = functionKeys.firstIndex(of: event.keyCode).map { "F\($0 + 1)" }
        let name = names[event.keyCode] ?? function ?? (event.charactersIgnoringModifiers ?? "").uppercased()
        let proposed = ShortcutBinding(keyCode: event.keyCode, modifiers: modifiers, keyName: name,
                                       enabled: binding?.enabled ?? true)
        if proposed.isSafe { pending = proposed; message = "Release to apply" }
        else { pending = nil; message = "Add ⌘, ⌃ or ⌥" }
        needsDisplay = true
    }
    override func keyUp(with event: NSEvent) {
        guard capturing, let pending, pending.keyCode == event.keyCode else { return }
        // Resume global registrations only after the recorded key has been released.
        _ = onCommit?(pending)
        window?.makeFirstResponder(nil)
    }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), xRadius: 9, yRadius: 9)
        NSColor.white.withAlphaComponent(capturing ? 0.12 : 0.055).setFill(); path.fill()
        (capturing ? NSColor(Palette.accent) : NSColor.white.withAlphaComponent(0.12)).setStroke(); path.stroke()
        let label = capturing ? message ?? "Press shortcut…" : binding?.label ?? "Unassigned"
        let text = NSAttributedString(string: label, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
                                                                 .foregroundColor: NSColor.white])
        let size = text.size()
        text.draw(at: NSPoint(x: max(4, (bounds.width - size.width) / 2), y: (bounds.height - size.height) / 2))
    }
}
