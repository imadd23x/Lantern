import Foundation
import Testing
@testable import LanternApp

@Test func onlyInstalledApplicationsCanRegisterOrConfigureConnections() {
    let home = URL(fileURLWithPath: "/Users/Fixture")
    let identity = "local.imad.Lantern"
    #expect(InstalledApplication.permitsConfiguration(bundleURL: home.appendingPathComponent("Applications/Lantern.app"), identifier: identity, isDemo: false, home: home))
    #expect(InstalledApplication.permitsConfiguration(bundleURL: URL(fileURLWithPath: "/Applications/Lantern.app"), identifier: identity, isDemo: false, home: home))
    for path in ["/private/tmp/Lantern.app", "/Users/Fixture/Downloads/Lantern.app", "/Users/Fixture/Applications/Lantern Review.app"] {
        #expect(!InstalledApplication.permitsConfiguration(bundleURL: URL(fileURLWithPath: path), identifier: identity, isDemo: false, home: home))
    }
    let canonical = home.appendingPathComponent("Applications/Lantern.app")
    #expect(!InstalledApplication.permitsConfiguration(bundleURL: canonical, identifier: identity, isDemo: true, home: home))
    #expect(!InstalledApplication.permitsConfiguration(bundleURL: canonical, identifier: "review.lantern", isDemo: false, home: home))
}
