// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TLDExtractSwift",
    products: [
        .library(
            name: "TLDExtractSwift",
            targets: ["TLDExtract"]),
    ],
    dependencies: [
        .package(url: "https://github.com/twodayslate/PunycodeSwift.git", .branch("master"))
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
