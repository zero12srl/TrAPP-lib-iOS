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
                      url: "https://trapp-artifact-ios.s3.eu-central-1.amazonaws.com/TrAPPSync-1.0.1.xcframework.zip",
                      checksum: "35cf6fa393d50349b9a81b727f183601a31c7dfbee41cb288ce4f3c007d16895")
    ]
)
