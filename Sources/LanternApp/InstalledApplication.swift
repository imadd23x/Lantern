import Foundation

enum InstalledApplication {
    static func permitsConfiguration(bundleURL: URL = Bundle.main.bundleURL,
                                     identifier: String? = Bundle.main.bundleIdentifier,
                                     isDemo: Bool, home: URL = FileManager.default.homeDirectoryForCurrentUser) -> Bool {
        guard !isDemo, identifier == "local.imad.Lantern" else { return false }
        let path = bundleURL.standardizedFileURL.path
        let locations = [home.appendingPathComponent("Applications/Lantern.app").standardizedFileURL.path,
                         "/Applications/Lantern.app"]
        return locations.contains(path) && bundleURL.resolvingSymlinksInPath().standardizedFileURL.path == path
    }
}
