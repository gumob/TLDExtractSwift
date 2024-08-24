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
        .package(url: "https://github.com/gumob/PunycodeSwift.git", .from: "2.1.0")
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
