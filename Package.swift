// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TLDExtract",
    products: [
        .library(
            name: "TLDExtract",
            targets: ["TLDExtract"])
    ],
    dependencies: [
        // .package(url: "https://github.com/gumob/PunycodeSwift.git", .from: "3.0.0"),
        .package(url: "https://github.com/gumob/PunycodeSwift.git", .branch("release/v3.0.0"))
    ],
    targets: [
        .target(
            name: "TLDExtract",
            dependencies: ["Punycode"],
            path: "Source"),
        .testTarget(
            name: "TLDExtractSwiftTests",
            dependencies: ["TLDExtract"],
            path: "Tests")
    ]
)
