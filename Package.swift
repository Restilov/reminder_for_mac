// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "ReminderForMac",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ReminderForMac",
            path: "Sources/ReminderForMac"
        )
    ]
)
