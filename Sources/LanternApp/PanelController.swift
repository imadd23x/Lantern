import AppKit
import SwiftUI

@MainActor
final class PanelController {
    private let panel: CompanionPanel
    private let model: AppModel
    private var screenObserver: NSObjectProtocol?

    init(model: AppModel) {
        self.model = model
        panel = CompanionPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                               backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.contentView = NSHostingView(rootView: CompanionView(model: model))
        model.onPresentationChange = { [weak self] in self?.layout() }
        screenObserver = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.layout() }
            }
    }

    func show() { layout(); panel.orderFrontRegardless() }

    func layout() {
        guard let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main else { return }
        let size = NSSize(width: model.expanded ? 460 : 246, height: model.expanded ? 584 : 46)
        // Sit immediately below the camera/menu bar, never covering system menus or the camera.
        let top = screen.frame.maxY - max(screen.safeAreaInsets.top, screen.frame.maxY - screen.visibleFrame.maxY) - 5
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height,
                              width: size.width, height: size.height), display: true)
    }
}

private final class CompanionPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
