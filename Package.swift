// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Lantern",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "Lantern", targets: ["LanternApp"]),
        .executable(name: "lantern-hook", targets: ["LanternHook"]),
    ],
    targets: [
        .target(name: "LanternCore"),
        .target(name: "LanternTransport", dependencies: ["LanternCore"]),
        .executableTarget(name: "LanternHook", dependencies: ["LanternCore", "LanternTransport"]),
        .executableTarget(name: "LanternApp", dependencies: ["LanternCore", "LanternTransport"],
                          resources: [.copy("Resources/ClaudeCode.webp"), .copy("Resources/Codex.png"),
                                      .copy("Resources/GreenLanternHead.png"), .copy("Resources/LanternEmblem.png"), .copy("Resources/A-Train.mp3")]),
        .target(name: "LanternTestSupport", dependencies: ["LanternCore", "LanternTransport"],
                path: "Tests/LanternTestSupport"),
        .testTarget(name: "LanternCoreTests", dependencies: ["LanternCore", "LanternTransport", "LanternTestSupport"]),
        .testTarget(name: "LanternAppTests", dependencies: ["LanternApp", "LanternCore", "LanternTransport", "LanternTestSupport"]),
    ]
)
