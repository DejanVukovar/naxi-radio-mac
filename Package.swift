// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NaxiRadio",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "NaxiRadio",
            path: "Sources/NaxiRadio"
        )
    ]
)
