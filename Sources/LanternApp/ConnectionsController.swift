import AppKit
import Combine
import SwiftUI

/// An independent transparent card avoids AppKit's rectangular dimming of a borderless sheet parent.
@MainActor
final class ConnectionsController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private var window: ConnectionsPanel?
    private var subscription: AnyCancellable?

    init(model: AppModel) {
        self.model = model
        super.init()
        subscription = model.$showConnections.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.model.showConnections { self.show() }
                else if self.window?.isVisible == true { self.window?.close() }
            }
        }
    }

    private func show() {
        guard window?.isVisible != true else { window?.makeKeyAndOrderFront(nil); return }
        model.refreshConnections()
        let window = ConnectionsPanel(contentRect: CGRect(x: 0, y: 0, width: 480, height: 310),
                                      styleMask: [.borderless], backing: .buffered, defer: false)
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 2)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.title = "Connect your agents"
        window.onClose = { [weak self] in self?.model.showConnections = false }
        let content = NSHostingView(rootView: ConnectionsView(model: model,
            onClose: { [weak self] in self?.model.showConnections = false },
            onHeightChange: { [weak self] height in self?.resize(height: height) }))
        content.sizingOptions = []
        window.contentView = content
        self.window = window
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func resize(height: CGFloat) {
        guard let window, height.isFinite, height > 0 else { return }
        let available = (window.screen ?? NSScreen.main)?.visibleFrame ?? window.frame
        let size = CGSize(width: 480, height: min(height.rounded(.up), available.height - 16))
        guard window.frame.size != size else { return }
        window.setFrame(PanelPlacement.frame(size: size,
            anchor: CGPoint(x: window.frame.midX, y: window.frame.maxY), bounds: available), display: true)
    }

    func close() { model.showConnections = false; window?.close() }
    func windowWillClose(_ notification: Notification) {
        if model.showConnections { model.showConnections = false }
        model.refreshConnections()
    }
}

private final class ConnectionsPanel: NSPanel {
    var onClose: (() -> Void)?
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    override func cancelOperation(_ sender: Any?) { onClose?() }
}
