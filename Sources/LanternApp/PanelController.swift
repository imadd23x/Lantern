import AppKit
import SwiftUI
import QuartzCore

@MainActor
final class PanelController: NSObject, NSWindowDelegate {
    private let panel: CompanionPanel
    private let model: AppModel
    private var screenObserver: NSObjectProtocol?
    private var motionObserver: NSObjectProtocol?
    private var anchor: CGPoint?
    private let defaults: UserDefaults
    private var layoutGeneration = 0
    private var animating = false
    private var delayedLayout: Task<Void, Never>?
    private var lastPresentationTime: TimeInterval = -.infinity
    private var reducedMotion: Bool {
        CommandLine.arguments.contains("--reduce-motion") || NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    init(model: AppModel, defaults: UserDefaults = .standard) {
        self.model = model
        self.defaults = defaults
        if let stored = defaults.dictionary(forKey: "companionPosition"),
           let x = stored["x"] as? Double, let y = stored["top"] as? Double, x.isFinite, y.isFinite {
            anchor = CGPoint(x: x, y: y)
        }
        panel = CompanionPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                               backing: .buffered, defer: false)
        super.init()
        panel.delegate = self
        panel.isMovable = true
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: CompanionView(model: model)
            .environment(\.lanternReduceMotion, CommandLine.arguments.contains("--reduce-motion")))
        model.onPresentationChange = { [weak self] in self?.present() }
        model.onResetPosition = { [weak self] in self?.resetPosition() }
        panel.onEscape = { [weak model] in
            guard let model else { return }
            if model.expanded { model.setExpanded(false) } else { model.hideCompanion() }
        }
        screenObserver = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.layout(animated: false) }
            }
        motionObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.layout(animated: false) }
            }
    }

    func show() { layout(animated: false); panel.orderFrontRegardless() }

    private func present() {
        delayedLayout?.cancel()
        let time = Date.timeIntervalSinceReferenceDate
        let holdClose = !model.expanded && time - lastPresentationTime > 0.45
        lastPresentationTime = time
        if model.companionHidden {
            layoutGeneration += 1; animating = false
            panel.orderOut(nil)
            layout(animated: false)
        } else {
            if panel.isVisible && holdClose && !reducedMotion {
                // Arc's settled close fades details before shrinking; a quick reversal skips the hold.
                delayedLayout = Task { [weak self] in
                    try? await Task.sleep(for: .milliseconds(60))
                    guard !Task.isCancelled, let self else { return }
                    self.layout(animated: true)
                }
            } else { layout(animated: panel.isVisible) }
            panel.orderFrontRegardless()
        }
    }

    private func resetPosition() {
        anchor = nil; defaults.removeObject(forKey: "companionPosition")
        layout(animated: false)
    }

    private func layout(animated: Bool) {
        let screen = anchor.flatMap { point in NSScreen.screens.first { $0.frame.contains(point) } }
            ?? NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main
        guard let screen else { return }
        let bounds = usableFrame(of: screen)
        let desired = anchor ?? CGPoint(x: screen.frame.midX, y: bounds.maxY - 8)
        let frame = PanelPlacement.frame(size: model.expanded ? PanelPlacement.expanded : PanelPlacement.compact,
                                         anchor: desired, bounds: bounds)
        layoutGeneration += 1
        let generation = layoutGeneration
        animating = true
        // Animate actual window bounds: compact/hidden presentations leave no expanded input surface.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animated && !reducedMotion ? 0.32 : 0
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.22, 1, 0.36, 1)
            panel.animator().setFrame(frame, display: true)
        } completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, self.layoutGeneration == generation else { return }
                self.animating = false
            }
        }
    }

    func windowDidMove(_ notification: Notification) {
        guard !animating, panel.isVisible else { return }
        let screen = panel.screen ?? NSScreen.main
        guard let screen else { return }
        let point = CGPoint(x: panel.frame.midX, y: panel.frame.maxY)
        let frame = PanelPlacement.frame(size: panel.frame.size, anchor: point, bounds: usableFrame(of: screen))
        anchor = CGPoint(x: frame.midX, y: frame.maxY)
        defaults.set(["x": Double(frame.midX), "top": Double(frame.maxY)], forKey: "companionPosition")
        if frame != panel.frame { panel.setFrame(frame, display: true) }
    }

    private func usableFrame(of screen: NSScreen) -> CGRect {
        let visible = screen.visibleFrame
        let top = min(visible.maxY, screen.frame.maxY - screen.safeAreaInsets.top)
        return CGRect(x: visible.minX, y: visible.minY, width: visible.width, height: top - visible.minY)
    }
}

private final class CompanionPanel: NSPanel {
    var onEscape: (() -> Void)?
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    override func cancelOperation(_ sender: Any?) { onEscape?() }
}
