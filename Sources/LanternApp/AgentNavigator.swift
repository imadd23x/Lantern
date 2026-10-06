import AppKit
import CoreGraphics
import LanternCore

enum AgentDestination: Equatable {
    case link(URL)
    case existingVSCode

    static func destination(for session: AgentSession) -> Self? {
        var url = URLComponents()
        if session.id.provider == .codex {
            url.scheme = "codex"; url.host = "threads"; url.path = "/" + session.id.id
        } else { return session.phase == .ended ? nil : .existingVSCode }
        return url.url.map(Self.link)
    }
}

/// One navigation seam for rows and permission handoff. The live adapter cannot open Claude
/// workspaces or chats; activation preserves VS Code's existing window and selected conversation.
@MainActor
struct AgentNavigator {
    let openURL: (URL) -> Bool
    let focusExistingCode: () -> Bool

    func open(_ session: AgentSession) -> String? {
        guard let destination = AgentDestination.destination(for: session) else {
            return "This Claude session has ended. Select the existing chat in VS Code."
        }
        switch destination {
        case .link(let url):
            return openURL(url) ? nil : "Could not open this Codex chat. Select it in Codex manually."
        case .existingVSCode:
            return focusExistingCode() ? nil : "VS Code has no available window. Open VS Code yourself and select the existing Claude chat."
        }
    }

    static var live: Self {
        Self(openURL: { NSWorkspace.shared.open($0) }, focusExistingCode: {
            guard let code = NSWorkspace.shared.runningApplications.first(where: {
                $0.bundleIdentifier == "com.microsoft.VSCode" && !$0.isTerminated
            }), hasEditorWindow(processID: code.processIdentifier) else { return false }
            return code.activate(options: [])
        })
    }

    private static func hasEditorWindow(processID: pid_t) -> Bool {
        // Owner PID/layer/bounds need no Accessibility or screen-recording grant. Do not read titles,
        // document content or transcript files, and do not start Code if its last window was closed.
        guard let windows = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID)
                as? [[String: Any]] else { return false }
        return windows.contains { window in
            guard (window[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value == processID,
                  (window[kCGWindowLayer as String] as? NSNumber)?.intValue == 0,
                  let bounds = window[kCGWindowBounds as String] as? NSDictionary else { return false }
            var rect = CGRect.zero
            return CGRectMakeWithDictionaryRepresentation(bounds as CFDictionary, &rect) && rect.width >= 160 && rect.height >= 100
        }
    }
}
