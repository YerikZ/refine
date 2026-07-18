// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Refine",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Refine", path: "Sources/Refine")
    ]
)
