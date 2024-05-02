// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TLDExtract",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "TLDExtract",
            targets: ["TLDExtract"])
    ],
    dependencies: [
        .package(url: "https://github.com/gumob/PunycodeSwift.git", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(
            name: "TLDExtract",
            dependencies: ["Punnycode"],
            path: "Source"),
        .testTarget(
            name: "TLDExtractSwiftTests",
            dependencies: ["TLDExtract"],
            path: "Tests")
    ]
)
