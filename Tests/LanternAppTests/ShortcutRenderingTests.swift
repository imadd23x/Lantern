import AppKit
import Testing
@testable import LanternApp

@MainActor
@Suite(.serialized)
struct ShortcutRenderingTests {
    @Test func clickingTheLabelTargetsTheRecorder() {
        let input = ShortcutInput(frame: NSRect(x: 0, y: 0, width: 132, height: 32))
        input.binding = ShortcutBinding.defaults[.allowOnce]
        input.layoutSubtreeIfNeeded()
        #expect(input.hitTest(NSPoint(x: 66, y: 16)) === input)
    }

    @Test func inactiveRecorderRemainsReadableAcrossFocusAndRecordingChanges() throws {
        _ = NSApplication.shared
        let input = ShortcutInput(frame: NSRect(x: 0, y: 0, width: 132, height: 32))
        let window = NSWindow(contentRect: input.bounds, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentView = input
        defer { window.close() }
        input.appearance = NSAppearance(named: .darkAqua)
        // Never order a test window on screen. Exercise the inactive renderer that crashed
        // while Connections took focus, using real shortcut glyphs and recorder states.
        for cycle in 0..<12 {
            input.binding = ShortcutBinding.defaults[cycle.isMultiple(of: 2) ? .allowOnce : .visibility]
            input.capturing = cycle.isMultiple(of: 3)
            if input.capturing {
                input.keyDown(with: try #require(NSEvent.keyEvent(with: .keyDown, location: .zero,
                    modifierFlags: .command, timestamp: 1, windowNumber: 0, context: nil,
                    characters: "\r", charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36)))
            }
            _ = window.makeFirstResponder(input)
            _ = window.makeFirstResponder(nil)
            input.layoutSubtreeIfNeeded()
            let bitmap = try #require(input.bitmapImageRepForCachingDisplay(in: input.bounds))
            input.cacheDisplay(in: input.bounds, to: bitmap)
            var ink = 0
            for x in 8..<(bitmap.pixelsWide - 8) {
                for y in 6..<(bitmap.pixelsHigh - 6) {
                    if let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB),
                       color.alphaComponent > 0.8, color.redComponent > 0.8 { ink += 1 }
                }
            }
            #expect(ink > 5, "Shortcut text must remain visible after inactive redraw \(cycle)")
            input.capturing = false
        }
    }
}
