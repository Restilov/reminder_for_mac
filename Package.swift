// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "AlarmForMac",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "AlarmForMac",
            path: "Sources/AlarmForMac"
        )
    ]
)
