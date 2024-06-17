// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyLogger",
    platforms: [
        .macOS(.v13),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "EasyLogger",
            targets: ["EasyLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "EasyLogger",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "EasyLoggerTests",
            dependencies: ["EasyLogger"]),
    ]
)
