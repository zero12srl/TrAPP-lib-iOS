// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrAPP-lib",
    platforms: [
        .macOS(.v10_15), .iOS(.v16), .tvOS(.v16)
    ],
    products: [
        .library(
            name: "TrAPP-lib",
            targets: ["TrAPP-lib"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "TrAPP-lib",
                      url: "https://trapp-artifact-ios.s3.eu-central-1.amazonaws.com/TrAPPSync-1.0.0.xcframework.zip",
                      checksum: "2c64f841e7dfecf65b507db375b31533348d073d0d26e63041ee1131545a3a13")
    ]
)
