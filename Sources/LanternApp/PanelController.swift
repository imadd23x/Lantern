import AppKit
import SwiftUI
import QuartzCore

@MainActor
final class PanelController: NSObject, NSWindowDelegate, NSGestureRecognizerDelegate {
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
    private var pillPan: NSPanGestureRecognizer?
    private var pillDrag: PanelDrag?
    private var interruptedApplication: NSRunningApplication?
    private var pointerTimer: Timer?
    private var hotspotEntry = PointerEntry(inside: false)
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
        panel.becomesKeyOnlyIfNeeded = true
        panel.keyboardFocusAllowed = { [weak model] in model?.allowsKeyboardFocus ?? false }
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: CompanionView(model: model)
            .environment(\.lanternReduceMotion, CommandLine.arguments.contains("--reduce-motion")))
        model.onPresentationChange = { [weak self] in self?.present() }
        model.onApprovalDecision = { [weak self] decision in
            if decision != .delegate { self?.returnKeyboardFocus() }
        }
        let pan = NSPanGestureRecognizer(target: self, action: #selector(dragPill(_:)))
        pan.buttonMask = 1
        pan.delaysPrimaryMouseButtonEvents = true
        pan.delegate = self
        panel.contentView?.addGestureRecognizer(pan)
        pillPan = pan
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
        // This observer survives ordering the panel out; it never installs an input surface or event tap.
        let timer = Timer(timeInterval: 0.15, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.samplePointer() }
        }
        pointerTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func show() { layout(animated: false); panel.orderFrontRegardless() }

    func stop() {
        pointerTimer?.invalidate(); pointerTimer = nil; delayedLayout?.cancel()
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        if let motionObserver { NSWorkspace.shared.notificationCenter.removeObserver(motionObserver) }
    }

    private func samplePointer() {
        let pointer = NSEvent.mouseLocation
        model.isPointerInside = panel.isVisible && panel.frame.contains(pointer)
        guard model.automaticallyHidden else { return }
        if hotspotEntry.entered(isInside: PanelPlacement.revealHotspot(for: panel.frame).contains(pointer)) {
            model.revealOnHover()
        }
    }

    private func present() {
        if !model.allowsKeyboardFocus { returnKeyboardFocus() }
        pillPan?.isEnabled = !model.expanded && !model.companionHidden && !model.showConnections
        delayedLayout?.cancel()
        let time = Date.timeIntervalSinceReferenceDate
        let holdClose = !model.expanded && time - lastPresentationTime > 0.45
        lastPresentationTime = time
        if model.companionHidden {
            layoutGeneration += 1; animating = false
            panel.orderOut(nil)
            layout(animated: false)
            hotspotEntry = PointerEntry(inside: PanelPlacement.revealHotspot(for: panel.frame).contains(NSEvent.mouseLocation))
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
            // Explicitly opening Lantern opts into its keyboard controls; alerts never do.
            if model.expanded && model.allowsKeyboardFocus { panel.makeKey() }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        !model.expanded && !model.companionHidden && !model.showConnections && event.type == .leftMouseDown
    }

    /// Delayed primary events reach SwiftUI only if the pan fails. A recognized drag therefore cannot
    /// click the chevron/close button. Expanded controls and sheets opt out before event arbitration.
    @objc private func dragPill(_ gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            model.isDragging = true
            delayedLayout?.cancel()
            layoutGeneration += 1
            animating = false
            panel.setFrame(panel.frame, display: true)
            pillDrag = PanelDrag(origin: panel.frame.origin,
                                 pointer: panel.convertPoint(toScreen: gesture.location(in: nil)),
                                 initialTranslation: gesture.translation(in: nil))
        case .changed, .ended: break
        default:
            pillDrag = nil; model.isDragging = false
            return
        }
        if let drag = pillDrag {
            // Convert each event to the fixed screen space before moving its coordinate system.
            let pointer = panel.convertPoint(toScreen: gesture.location(in: nil))
            panel.setFrameOrigin(drag.origin(at: pointer))
        }
        if gesture.state == .ended { pillDrag = nil; model.isDragging = false }
    }

    private func layout(animated: Bool) {
        let screen = anchor.flatMap { point in NSScreen.screens.first { $0.frame.contains(point) } }
            ?? NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main
        guard let screen else { return }
        let bounds = usableFrame(of: screen)
        let desired = anchor ?? CGPoint(x: screen.frame.midX, y: bounds.maxY - 8)
        let frame = PanelPlacement.frame(size: model.expanded ? PanelPlacement.expanded : PanelPlacement.compact,
                                         anchor: desired, bounds: bounds)
        if model.automaticallyHidden {
            hotspotEntry = PointerEntry(inside: PanelPlacement.revealHotspot(for: frame).contains(NSEvent.mouseLocation))
        }
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
        model.recordInteraction()
        let screen = panel.screen ?? NSScreen.main
        guard let screen else { return }
        let point = CGPoint(x: panel.frame.midX, y: panel.frame.maxY)
        let frame = PanelPlacement.frame(size: panel.frame.size, anchor: point, bounds: usableFrame(of: screen))
        anchor = CGPoint(x: frame.midX, y: frame.maxY)
        defaults.set(["x": Double(frame.midX), "top": Double(frame.maxY)], forKey: "companionPosition")
        if frame != panel.frame { panel.setFrame(frame, display: true) }
    }

    func windowDidBecomeKey(_ notification: Notification) {
        if let app = NSWorkspace.shared.frontmostApplication,
           app.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            interruptedApplication = app
        }
    }

    private func returnKeyboardFocus() {
        guard panel.isKeyWindow else { return }
        let previous = interruptedApplication
        interruptedApplication = nil
        panel.resignKey()
        guard let previous, !previous.isTerminated,
              let current = NSWorkspace.shared.frontmostApplication,
              current.processIdentifier == previous.processIdentifier
                || current.processIdentifier == ProcessInfo.processInfo.processIdentifier else { return }
        previous.activate(options: [])
    }

    private func usableFrame(of screen: NSScreen) -> CGRect {
        let visible = screen.visibleFrame
        let top = min(visible.maxY, screen.frame.maxY - screen.safeAreaInsets.top)
        return CGRect(x: visible.minX, y: visible.minY, width: visible.width, height: top - visible.minY)
    }
}

private final class CompanionPanel: NSPanel {
    var onEscape: (() -> Void)?
    var keyboardFocusAllowed: (() -> Bool)?
    override var canBecomeKey: Bool { keyboardFocusAllowed?() ?? false }
    override var canBecomeMain: Bool { false }
    override func cancelOperation(_ sender: Any?) { onEscape?() }
}
