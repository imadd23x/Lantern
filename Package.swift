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
                          resources: [.copy("Resources/ClaudeCode.webp"), .copy("Resources/Codex.png")]),
        .testTarget(name: "LanternCoreTests", dependencies: ["LanternCore", "LanternTransport"]),
        .testTarget(name: "LanternAppTests", dependencies: ["LanternApp", "LanternCore", "LanternTransport"]),
    ]
)
