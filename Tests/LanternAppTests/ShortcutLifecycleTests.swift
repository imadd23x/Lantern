import AppKit
import Testing
@testable import LanternApp

@Test func heldShortcutSurvivesSuspensionUntilItsRelease() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce)
    let first = lifecycle.press(.allowOnce)
    #expect(first)
    let removed = lifecycle.remove(1)
    #expect(!removed) // Retain the native registration to receive release.
    #expect(lifecycle.isPressed(.allowOnce))
    let repeated = lifecycle.press(.allowOnce)
    #expect(!repeated)
    let released = lifecycle.release(.allowOnce)
    #expect(released == [1])
    lifecycle.registered(2, for: .allowOnce)
    let next = lifecycle.press(.allowOnce)
    let repeatNext = lifecycle.press(.allowOnce)
    #expect(next && !repeatNext)
    let stopped = lifecycle.stop()
    #expect(stopped == [2] && !lifecycle.isPressed(.allowOnce))
}

@Test func shortcutAlreadyHeldAtRegistrationCannotApproveANewRequest() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce, alreadyPressed: true)
    let repeatBeforeRelease = lifecycle.press(.allowOnce)
    #expect(!repeatBeforeRelease)
    _ = lifecycle.release(.allowOnce)
    let freshPress = lifecycle.press(.allowOnce)
    #expect(freshPress)
}

@MainActor
@Test func commandReleaseCompletesRecorderExactlyOnce() throws {
    let input = ShortcutInput(frame: .zero)
    input.capturing = true
    var bindings: [ShortcutBinding] = []
    input.onCommit = { bindings.append($0); return true }
    let down = try #require(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: .command,
        timestamp: 1, windowNumber: 0, context: nil, characters: "\r", charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36))
    let up = try #require(NSEvent.keyEvent(with: .keyUp, location: .zero, modifierFlags: .command,
        timestamp: 2, windowNumber: 0, context: nil, characters: "\r", charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36))
    input.keyDown(with: down)
    input.keyUp(with: up)
    input.keyUp(with: up)
    #expect(bindings == [ShortcutBinding(keyCode: 36, modifiers: .command, keyName: "Return")])
    #expect(!input.capturing)
}
