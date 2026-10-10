import Carbon
import CoreGraphics
import Foundation

private func lanternHotKeyHandler(_: EventHandlerCallRef?, event: EventRef?, context: UnsafeMutableRawPointer?) -> OSStatus {
    guard let event, let context else { return OSStatus(eventNotHandledErr) }
    var identifier = EventHotKeyID()
    let status = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                   nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
    guard status == noErr, identifier.signature == CarbonShortcuts.signature else { return OSStatus(eventNotHandledErr) }
    let owner = Unmanaged<CarbonShortcuts>.fromOpaque(context).takeUnretainedValue()
    let token = identifier.id
    let pressed = GetEventKind(event) == UInt32(kEventHotKeyPressed)
    let timestamp = GetEventTime(event)
    MainActor.assumeIsolated { owner.receive(token, pressed: pressed, at: timestamp) }
    return noErr
}

/// Native hotkeys without recording general keyboard input or requiring Accessibility access.
@MainActor
final class CarbonShortcuts {
    nonisolated static let signature: UInt32 = 0x4C414E54
    var onAction: ((ShortcutAction, Int, TimeInterval) -> Void)?
    var onRelease: (() -> Void)?
    private var handler: EventHandlerRef?
    private var references: [Int: (native: EventHotKeyRef, keyCode: CGKeyCode)] = [:]
    private var lifecycle = ShortcutLifecycle()
    private var nextToken = 0
    private var releaseTimer: Timer?

    init() {
        var specifications = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased))
        ]
        let result = InstallEventHandler(GetApplicationEventTarget(), lanternHotKeyHandler, specifications.count,
                                         &specifications, Unmanaged.passUnretained(self).toOpaque(), &handler)
        if result != noErr { handler = nil }
    }

    func isPressed(_ action: ShortcutAction) -> Bool { lifecycle.isPressed(action) }

    func register(_ action: ShortcutAction, binding: ShortcutBinding) -> Int? {
        guard handler != nil, binding.isSafe, binding.enabled, !isPressed(action),
              nextToken < UInt32.max else { return nil }
        var modifiers: UInt32 = 0
        if binding.modifiers.contains(.command) { modifiers |= UInt32(cmdKey) }
        if binding.modifiers.contains(.option) { modifiers |= UInt32(optionKey) }
        if binding.modifiers.contains(.control) { modifiers |= UInt32(controlKey) }
        if binding.modifiers.contains(.shift) { modifiers |= UInt32(shiftKey) }
        var reference: EventHotKeyRef?
        nextToken += 1 // Never reuse a native event identity, including failed registrations.
        let identifier = EventHotKeyID(signature: Self.signature, id: UInt32(nextToken))
        guard RegisterEventHotKey(UInt32(binding.keyCode), modifiers, identifier, GetApplicationEventTarget(),
                                  0, &reference) == noErr, let reference else { return nil }
        references[nextToken] = (reference, CGKeyCode(binding.keyCode))
        // A request arriving during an existing modified press must wait for release.
        let held = CGEventSource.keyState(.combinedSessionState, key: CGKeyCode(binding.keyCode))
        lifecycle.registered(nextToken, for: action, alreadyPressed: held)
        reconcileReleaseTimer()
        return nextToken
    }

    func unregister(_ token: Int) {
        guard lifecycle.remove(token), let reference = references.removeValue(forKey: token) else { return }
        UnregisterEventHotKey(reference.native)
    }

    func stop() {
        for token in lifecycle.stop() {
            if let reference = references.removeValue(forKey: token) { UnregisterEventHotKey(reference.native) }
        }
        releaseTimer?.invalidate(); releaseTimer = nil
        onRelease = nil
        onAction = nil
        if let handler { RemoveEventHandler(handler) }
        handler = nil
    }

    fileprivate func receive(_ identifier: UInt32, pressed: Bool, at timestamp: TimeInterval) {
        let token = Int(identifier)
        guard references[token] != nil else { return }
        if pressed {
            guard let action = lifecycle.press(token) else { return }
            reconcileReleaseTimer()
            onAction?(action, token, timestamp)
        } else {
            release(token)
        }
    }

    private func release(_ token: Int) {
        let wasHeld = lifecycle.heldTokens.contains(token)
        for retired in lifecycle.release(token) {
            if let reference = references.removeValue(forKey: retired) { UnregisterEventHotKey(reference.native) }
        }
        reconcileReleaseTimer()
        if wasHeld { onRelease?() }
    }

    /// Carbon may omit key-up when registered during a press. Sample only held
    /// registered keys, and stop sampling as soon as those keys have been released.
    private func reconcileReleaseTimer() {
        if lifecycle.heldTokens.isEmpty {
            releaseTimer?.invalidate(); releaseTimer = nil
        } else if releaseTimer == nil {
            releaseTimer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    for token in self.lifecycle.heldTokens {
                        guard let reference = self.references[token],
                              !CGEventSource.keyState(.combinedSessionState, key: reference.keyCode) else { continue }
                        self.release(token)
                    }
                }
            }
            RunLoop.main.add(releaseTimer!, forMode: .common)
        }
    }
}
