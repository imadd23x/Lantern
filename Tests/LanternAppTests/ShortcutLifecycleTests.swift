import AppKit
import Testing
@testable import LanternApp

@Test func retiredShortcutCannotLatchAKeyForTheNextApproval() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce)
    let removed = lifecycle.remove(1)
    #expect(removed)
    let stale = lifecycle.press(1)
    #expect(stale == nil)
    #expect(!lifecycle.isPressed(.allowOnce))
}

@Test func heldShortcutSurvivesSuspensionUntilItsRelease() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce)
    let first = lifecycle.press(1)
    #expect(first == .allowOnce)
    let removed = lifecycle.remove(1)
    #expect(!removed) // Retain the native registration to receive release.
    #expect(lifecycle.isPressed(.allowOnce))
    let repeated = lifecycle.press(1)
    #expect(repeated == nil)
    let released = lifecycle.release(1)
    #expect(released == [1])
    lifecycle.registered(2, for: .allowOnce)
    let next = lifecycle.press(2)
    let repeatNext = lifecycle.press(2)
    #expect(next == .allowOnce && repeatNext == nil)
    let stopped = lifecycle.stop()
    #expect(stopped == [2] && !lifecycle.isPressed(.allowOnce))
}

@Test func shortcutAlreadyHeldAtRegistrationCannotApproveANewRequest() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce, alreadyPressed: true)
    let repeatBeforeRelease = lifecycle.press(1)
    #expect(repeatBeforeRelease == nil)
    _ = lifecycle.release(1)
    let freshPress = lifecycle.press(1)
    #expect(freshPress == .allowOnce)
}

@Test func staleReleaseCannotReleaseTheNextRequestsHeldPress() {
    var lifecycle = ShortcutLifecycle()
    lifecycle.registered(1, for: .allowOnce)
    _ = lifecycle.remove(1)
    lifecycle.registered(2, for: .allowOnce)
    _ = lifecycle.press(2)
    _ = lifecycle.release(1)
    let repeated = lifecycle.press(2)
    #expect(lifecycle.isPressed(.allowOnce) && repeated == nil)
    _ = lifecycle.release(2)
    let fresh = lifecycle.press(2)
    #expect(fresh == .allowOnce)
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
