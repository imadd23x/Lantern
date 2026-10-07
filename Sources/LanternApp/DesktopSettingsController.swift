import AppKit
import SwiftUI

@MainActor
final class DesktopSettingsController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private let shortcuts: ShortcutController
    private let login: LoginItemController
    private var window: NSWindow?

    init(model: AppModel, shortcuts: ShortcutController, login: LoginItemController) {
        self.model = model; self.shortcuts = shortcuts; self.login = login
        super.init()
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

    func close() { window?.close() }
    func windowWillClose(_ notification: Notification) { shortcuts.recording = nil; model.isSettingsOpen = false }
    func windowDidResignKey(_ notification: Notification) { shortcuts.recording = nil }
}
