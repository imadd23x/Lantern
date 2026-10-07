import Carbon
import Foundation

private func lanternHotKeyHandler(_: EventHandlerCallRef?, event: EventRef?, context: UnsafeMutableRawPointer?) -> OSStatus {
    guard let event, let context else { return OSStatus(eventNotHandledErr) }
    var identifier = EventHotKeyID()
    let status = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                   nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
    guard status == noErr, identifier.signature == CarbonShortcuts.signature else { return OSStatus(eventNotHandledErr) }
    let owner = Unmanaged<CarbonShortcuts>.fromOpaque(context).takeUnretainedValue()
    let actionID = identifier.id
    // Carbon's application event target delivers on the application's main event loop.
    MainActor.assumeIsolated { owner.receive(actionID) }
    return noErr
}

/// Native hotkeys, without recording general keyboard input or requiring Accessibility access.
@MainActor
final class CarbonShortcuts {
    nonisolated static let signature: UInt32 = 0x4C414E54
    private let onAction: (ShortcutAction) -> Void
    private var handler: EventHandlerRef?
    private var references: [Int: EventHotKeyRef] = [:]
    private var nextToken = 0

    init(onAction: @escaping (ShortcutAction) -> Void) {
        self.onAction = onAction
        var specification = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let result = InstallEventHandler(GetApplicationEventTarget(), lanternHotKeyHandler, 1, &specification,
                                         Unmanaged.passUnretained(self).toOpaque(), &handler)
        if result != noErr { handler = nil }
    }

    func register(_ action: ShortcutAction, binding: ShortcutBinding) -> Int? {
        guard handler != nil, binding.isSafe, binding.enabled,
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
        return nextToken
    }

    func unregister(_ token: Int) {
        if let reference = references.removeValue(forKey: token) { UnregisterEventHotKey(reference) }
    }

    func stop() {
        for reference in references.values { UnregisterEventHotKey(reference) }
        references.removeAll()
        if let handler { RemoveEventHandler(handler) }
        handler = nil
    }

    fileprivate func receive(_ identifier: UInt32) {
        let actions = ShortcutAction.allCases
        guard identifier > 0, identifier <= actions.count else { return }
        onAction(actions[Int(identifier) - 1])
    }
}
