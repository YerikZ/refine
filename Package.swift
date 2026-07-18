// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Retone",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Retone", path: "Sources/Retone")
    ]
)
