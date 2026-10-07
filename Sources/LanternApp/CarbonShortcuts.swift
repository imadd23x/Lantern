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
    let actionID = identifier.id
    let pressed = GetEventKind(event) == UInt32(kEventHotKeyPressed)
    MainActor.assumeIsolated { owner.receive(actionID, pressed: pressed) }
    return noErr
}

/// Native hotkeys without recording general keyboard input or requiring Accessibility access.
@MainActor
final class CarbonShortcuts {
    nonisolated static let signature: UInt32 = 0x4C414E54
    private let onAction: (ShortcutAction) -> Void
    var onRelease: (() -> Void)?
    private var handler: EventHandlerRef?
    private var references: [Int: EventHotKeyRef] = [:]
    private var lifecycle = ShortcutLifecycle()
    private var nextToken = 0

    init(onAction: @escaping (ShortcutAction) -> Void) {
        self.onAction = onAction
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
              let index = ShortcutAction.allCases.firstIndex(of: action) else { return nil }
        var modifiers: UInt32 = 0
        if binding.modifiers.contains(.command) { modifiers |= UInt32(cmdKey) }
        if binding.modifiers.contains(.option) { modifiers |= UInt32(optionKey) }
        if binding.modifiers.contains(.control) { modifiers |= UInt32(controlKey) }
        if binding.modifiers.contains(.shift) { modifiers |= UInt32(shiftKey) }
        var reference: EventHotKeyRef?
        let identifier = EventHotKeyID(signature: Self.signature, id: UInt32(index + 1))
        guard RegisterEventHotKey(UInt32(binding.keyCode), modifiers, identifier, GetApplicationEventTarget(),
                                  0, &reference) == noErr, let reference else { return nil }
        nextToken += 1
        references[nextToken] = reference
        // A request arriving during an existing modified press must wait for release.
        let flags = CGEventSource.flagsState(.combinedSessionState)
        let required: [(ShortcutModifiers, CGEventFlags)] = [(.command, .maskCommand), (.option, .maskAlternate),
                                                              (.control, .maskControl), (.shift, .maskShift)]
        let modifiersDown = required.allSatisfy { binding.modifiers.contains($0.0) == flags.contains($0.1) }
        let held = modifiersDown && CGEventSource.keyState(.combinedSessionState, key: CGKeyCode(binding.keyCode))
        lifecycle.registered(nextToken, for: action, alreadyPressed: held)
        return nextToken
    }

    func unregister(_ token: Int) {
        guard lifecycle.remove(token), let reference = references.removeValue(forKey: token) else { return }
        UnregisterEventHotKey(reference)
    }

    func stop() {
        for token in lifecycle.stop() {
            if let reference = references.removeValue(forKey: token) { UnregisterEventHotKey(reference) }
        }
        onRelease = nil
        if let handler { RemoveEventHandler(handler) }
        handler = nil
    }

    fileprivate func receive(_ identifier: UInt32, pressed: Bool) {
        let actions = ShortcutAction.allCases
        guard identifier > 0, identifier <= actions.count else { return }
        let action = actions[Int(identifier) - 1]
        if pressed {
            guard lifecycle.press(action) else { return }
            onAction(action)
        } else {
            for token in lifecycle.release(action) {
                if let reference = references.removeValue(forKey: token) { UnregisterEventHotKey(reference) }
            }
            onRelease?()
        }
    }
}
