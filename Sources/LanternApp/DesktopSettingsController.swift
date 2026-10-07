import AppKit
import SwiftUI
import Combine

@MainActor
final class DesktopSettingsController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private let shortcuts: ShortcutController
    private let login: LoginItemController
    private var window: NSWindow?
    private let selection = SettingsSelection()
    private var recordingChanged: AnyCancellable?
    private var releaseMonitor: Any?

    init(model: AppModel, shortcuts: ShortcutController, login: LoginItemController) {
        self.model = model; self.shortcuts = shortcuts; self.login = login
        super.init()
        recordingChanged = shortcuts.$recording.sink { [weak self] action in
            self?.monitorRelease(recording: action != nil)
        }
    }

    func show(section: SettingsSection = .general) {
        selection.section = section
        shortcuts.recording = nil
        login.refresh()
        if window == nil {
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 500, height: 400),
                                  styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "Lantern settings"
            window.minSize = CGSize(width: 500, height: 300)
            window.isReleasedWhenClosed = false
            window.delegate = self
            let content = NSHostingView(rootView: DesktopSettingsView(model: model,
                preferences: model.desktopPreferences, shortcuts: shortcuts, login: login, selection: selection,
                onClose: { [weak self] in self?.window?.close() },
                onHeightChange: { [weak self] height in self?.resize(height: height) }))
            // The measured content owns sizing; hosting-view window constraints must not pin the old tab.
            content.sizingOptions = []
            window.contentView = content
            window.center()
            self.window = window
        }
        model.isSettingsOpen = true
        // The companion is status-bar level; normal-level Settings would remain behind it.
        window?.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func resize(height: CGFloat) {
        guard let window, height.isFinite, height > 0 else { return }
        let bounds = (window.screen ?? NSScreen.main)?.visibleFrame ?? window.frame
        let titlebar = window.frame.height - window.contentRect(forFrameRect: window.frame).height
        let frame = PanelPlacement.frame(size: CGSize(width: 500, height: height.rounded(.up) + titlebar),
            anchor: CGPoint(x: window.frame.midX, y: window.frame.maxY), bounds: bounds)
        guard frame != window.frame else { return }
        let reduced = CommandLine.arguments.contains("--reduce-motion") || NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        window.setFrame(frame, display: true, animate: window.isVisible && !reduced)
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
    func windowDidResignKey(_ notification: Notification) {
        shortcuts.recording = nil
        window?.level = .normal
    }
    func windowDidBecomeKey(_ notification: Notification) {
        window?.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
        login.refresh()
    }
}
