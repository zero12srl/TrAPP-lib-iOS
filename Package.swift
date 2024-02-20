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
                      url: "https://trapp-artifact-ios.s3.eu-central-1.amazonaws.com/TrAPPSync-1.0.2.xcframework.zip",
                      checksum: "ea6f20a7643124c49fb88108f05b57b997870a8610bc402a6e9ac3731cf199c2")
    ]
)
