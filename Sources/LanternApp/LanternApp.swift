import AppKit
import SwiftUI
import Combine

@main
struct LanternApplication {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        if let index = CommandLine.arguments.firstIndex(of: "--render-icon"),
           CommandLine.arguments.indices.contains(index + 1) {
            do { try IconRenderer.writeIconset(to: URL(fileURLWithPath: CommandLine.arguments[index + 1])) }
            catch { fputs("Icon rendering failed: \(error.localizedDescription)\n", stderr); exit(1) }
            return
        }
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
        withExtendedLifetime(delegate) {}
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let model = AppModel(demo: CommandLine.arguments.contains("--demo"))
    private var panel: PanelController?
    private var item: NSStatusItem?
    private var stateSubscription: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = PanelController(model: model)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item?.button?.image = NSImage(systemSymbolName: "lamp.desk.fill", accessibilityDescription: "Lantern agent companion")
        item?.menu = makeMenu()
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem()
        applicationItem.submenu = makeMenu()
        mainMenu.addItem(applicationItem)
        NSApplication.shared.mainMenu = mainMenu
        model.start()
        panel?.show()
        stateSubscription = model.$state.sink { [weak self] state in
            let count = state.approvals.count
            self?.item?.button?.image = NSImage(systemSymbolName: count > 0 ? "exclamationmark.circle.fill" : "lamp.desk.fill",
                accessibilityDescription: count > 0 ? "Lantern: \(count) pending requests" : "Lantern agent companion")
        }
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Lantern", action: #selector(show), keyEquivalent: "")
        menu.addItem(withTitle: "Hide Lantern (keep listening)", action: #selector(hide), keyEquivalent: "")
        menu.addItem(withTitle: "Reset position", action: #selector(resetPosition), keyEquivalent: "")
        menu.addItem(withTitle: "Connections…", action: #selector(connections), keyEquivalent: ",")
        menu.addItem(withTitle: "Quiet mode", action: #selector(quiet(_:)), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Lantern", action: #selector(quit), keyEquivalent: "q")
        for menuItem in menu.items { menuItem.target = self }
        menu.delegate = self
        return menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.items.first(where: { $0.action == #selector(quiet(_:)) })?.state = model.quiet ? .on : .off
        let count = model.state.approvals.count
        menu.items.first(where: { $0.action == #selector(show) })?.title = count > 0 ? "Show Lantern · \(count) pending requests" : "Show Lantern"
    }

    func applicationWillTerminate(_ notification: Notification) { model.stop() }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        model.showCompanion()
        return false
    }
    @objc private func show() { model.showCompanion() }
    @objc private func hide() { model.hideCompanion() }
    @objc private func resetPosition() { model.resetPosition(); model.showCompanion() }
    @objc private func connections() { model.showConnections = true; show() }
    @objc private func quiet(_ sender: NSMenuItem) {
        model.quiet.toggle(); sender.state = model.quiet ? .on : .off
    }
    @objc private func quit() { NSApplication.shared.terminate(nil) }
}
