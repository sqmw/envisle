// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Envisle",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .library(name: "EnvisleDomain", targets: ["EnvisleDomain"]),
    ],
    targets: [
        .target(name: "EnvisleDomain"),
        .testTarget(name: "EnvisleDomainTests", dependencies: ["EnvisleDomain"]),
    ]
)
