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
                      url: "https://trapp-artifact-ios.s3.eu-central-1.amazonaws.com/TrAPPSync-1.1.0.xcframework.zip",
                      checksum: "8a5c74cc2eaf0649a9a5b0d8d127ae22295a8e9f9b81fd3b9cebef6d5e70dd1c")
    ]
)
