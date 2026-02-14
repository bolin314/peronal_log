// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VoiceLog",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "LogCore", targets: ["LogCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "LogCore",
            dependencies: ["WhisperKit"],
            path: "Sources/LogCore"
        ),
        .testTarget(
            name: "LogCoreTests",
            dependencies: ["LogCore"],
            path: "Tests/LogCoreTests"
        ),
    ]
)
