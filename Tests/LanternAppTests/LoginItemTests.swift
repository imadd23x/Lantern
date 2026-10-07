import Testing
@testable import LanternApp

@MainActor
@Test func loginStateReflectsOSApprovalAndPreservesStateOnErrors() {
    enum Failure: Error { case expected }
    var state: LoginItemStatus = .off
    var fails = false
    let controller = LoginItemController(read: { state }, write: { enabled in
        if fails { throw Failure.expected }
        state = enabled ? .requiresApproval : .off
    })
    controller.setEnabled(true)
    #expect(controller.enabled && controller.status == .requiresApproval)
    fails = true
    controller.setEnabled(false)
    #expect(controller.enabled && controller.error != nil)
    fails = false
    controller.setEnabled(false)
    #expect(!controller.enabled && controller.status == .off && controller.error == nil)
}

@MainActor
@Test func demoAndUnsupportedAppsCannotRegisterLoginItems() {
    let controller = LoginItemController(supported: false, read: { .unavailable },
                                         write: { _ in Issue.record("Unexpected OS registration") })
    controller.setEnabled(true)
    #expect(controller.status == .unavailable && !controller.enabled && controller.error != nil)
}
