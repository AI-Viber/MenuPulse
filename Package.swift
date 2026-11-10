// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MenuPulse",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MenuPulse",
            path: "Sources/MenuPulse",
            linkerSettings: [.linkedFramework("IOKit")]
        )
    ]
)
