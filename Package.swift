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
                      url: "https://trapp-artifact-ios.s3.eu-central-1.amazonaws.com/TrAPPSync-1.0.3.xcframework.zip",
                      checksum: "5a4adcfc2be059a68e29347ae566e9bfa0567a3cfa8bb0a186b96e2f8566e466")
    ]
)
