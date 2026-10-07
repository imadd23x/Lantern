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
    private var shortcuts: ShortcutController?
    private var settings: DesktopSettingsController?
    private var item: NSStatusItem?
    private var stateSubscription: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = PanelController(model: model)
        let shortcuts = ShortcutController(preferences: model.desktopPreferences, onAction: model.performShortcut,
            isAvailable: { [weak model] in $0 != .allowOnce || model?.allowsGlobalApproval == true },
            availabilityChanges: model.objectWillChange)
        self.shortcuts = shortcuts
        settings = DesktopSettingsController(model: model, shortcuts: shortcuts, login: .live(isDemo: model.isDemo))
        model.onSettingsRequest = { [weak self] in self?.settings?.show() }
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
        menu.addItem(withTitle: model.visibilityMenuTitle, action: #selector(toggleVisibility), keyEquivalent: "")
        menu.addItem(withTitle: "Settings…", action: #selector(openSettings), keyEquivalent: "")
        menu.addItem(withTitle: "Keep visible", action: #selector(pin(_:)), keyEquivalent: "")
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
        menu.items.first(where: { $0.action == #selector(toggleVisibility) })?.title = model.visibilityMenuTitle
        menu.items.first(where: { $0.action == #selector(pin(_:)) })?.state = model.desktopPreferences.pinned ? .on : .off
    }

    func menuWillOpen(_ menu: NSMenu) { model.isMenuOpen = true }
    func menuDidClose(_ menu: NSMenu) { model.isMenuOpen = false }
    func applicationWillTerminate(_ notification: Notification) { settings?.close(); shortcuts?.stop(); panel?.stop(); model.stop() }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        model.showCompanion()
        return false
    }
    @objc private func toggleVisibility() { model.toggleCompanionVisibility() }
    @objc private func openSettings() { settings?.show() }
    @objc private func pin(_ sender: NSMenuItem) { model.desktopPreferences.pinned.toggle() }
    @objc private func connections() { model.showConnections = true; model.showCompanion(expanded: true) }
    @objc private func quiet(_ sender: NSMenuItem) {
        model.quiet.toggle(); sender.state = model.quiet ? .on : .off
    }
    @objc private func quit() { NSApplication.shared.terminate(nil) }
}
