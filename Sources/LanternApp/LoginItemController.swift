import Combine
import Foundation
import ServiceManagement

enum LoginItemStatus { case off, on, requiresApproval, unavailable }

@MainActor
final class LoginItemController: ObservableObject {
    @Published private(set) var status: LoginItemStatus
    @Published private(set) var error: String?
    let supported: Bool
    private let read: () -> LoginItemStatus
    private let write: (Bool) throws -> Void
    var enabled: Bool { status == .on || status == .requiresApproval }

    init(supported: Bool = true, read: @escaping () -> LoginItemStatus, write: @escaping (Bool) throws -> Void) {
        self.supported = supported; self.read = read; self.write = write
        status = read()
    }

    func refresh() { status = read() }
    func setEnabled(_ enabled: Bool) {
        guard supported else { error = "Launch at login is available in the installed Lantern app."; return }
        do { try write(enabled); error = nil }
        catch { self.error = "macOS could not update the login item: " + error.localizedDescription }
        status = read()
    }

    static func live(isDemo: Bool) -> LoginItemController {
        let supported = !isDemo && Bundle.main.bundleIdentifier == "local.imad.Lantern"
            && Bundle.main.bundleURL.pathExtension == "app"
        return Self(supported: supported, read: {
            guard supported else { return .unavailable }
            switch SMAppService.mainApp.status {
            case .enabled: return .on
            case .notRegistered: return .off
            case .requiresApproval: return .requiresApproval
            case .notFound: return .unavailable
            @unknown default: return .unavailable
            }
        }, write: { enabled in
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        })
    }
}
