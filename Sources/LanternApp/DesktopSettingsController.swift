import AppKit
import SwiftUI
import Combine

@MainActor
final class DesktopSettingsController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private let shortcuts: ShortcutController
    private let login: LoginItemController
    private var window: NSWindow?
    private var recordingChanged: AnyCancellable?
    private var releaseMonitor: Any?

    init(model: AppModel, shortcuts: ShortcutController, login: LoginItemController) {
        self.model = model; self.shortcuts = shortcuts; self.login = login
        super.init()
        recordingChanged = shortcuts.$recording.sink { [weak self] action in
            self?.monitorRelease(recording: action != nil)
        }
    }

    func show() {
        shortcuts.recording = nil
        login.refresh()
        if window == nil {
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 560, height: 640),
                                  styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
            window.title = "Lantern settings"
            window.minSize = CGSize(width: 500, height: 440)
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.contentView = NSHostingView(rootView: DesktopSettingsView(model: model,
                preferences: model.desktopPreferences, shortcuts: shortcuts, login: login,
                onClose: { [weak self] in self?.window?.close() }))
            window.center()
            self.window = window
        }
        model.isSettingsOpen = true
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func monitorRelease(recording: Bool) {
        if let releaseMonitor { NSEvent.removeMonitor(releaseMonitor); self.releaseMonitor = nil }
        guard recording else { return }
        // App-local only: Command key equivalents may bypass NSView.keyUp.
        releaseMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
            MainActor.assumeIsolated {
                if let window = self?.window, window.isKeyWindow,
                   let input = window.firstResponder as? ShortcutInput, input.capturing {
                    input.keyUp(with: event)
                }
            }
            return event
        }
    }

    func close() { shortcuts.recording = nil; monitorRelease(recording: false); window?.close() }
    func windowWillClose(_ notification: Notification) { shortcuts.recording = nil; model.isSettingsOpen = false }
    func windowDidResignKey(_ notification: Notification) { shortcuts.recording = nil }
    func windowDidBecomeKey(_ notification: Notification) { login.refresh() }
}
