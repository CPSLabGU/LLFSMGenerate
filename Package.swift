// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package definition.
let package = Package(
    name: "VHDLMachineTransformations",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other
        // packages.
        .library(
            name: "VHDLMachineTransformations",
            targets: ["VHDLMachineTransformations", "JavascriptModel"]
        ),
        .executable(
            name: "llfsmgenerate",
            targets: ["MachineGenerator", "VHDLMachineTransformations", "JavascriptModel"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/mipalgu/VHDLMachines", from: "1.2.4"),
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "2.4.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JavascriptModel"
        ),
        .executableTarget(
            name: "MachineGenerator",
            dependencies: [
                .target(name: "JavascriptModel"),
                .target(name: "VHDLMachineTransformations"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing")
            ]
        ),
        .target(
            name: "VHDLMachineTransformations",
            dependencies: [
                .target(name: "JavascriptModel"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing")
            ]
        ),
        .testTarget(name: "JavascriptModelTests", dependencies: ["JavascriptModel"]),
        .testTarget(
            name: "MachineGeneratorTests",
            dependencies: [
                .target(name: "MachineGenerator"),
                .target(name: "JavascriptModel"),
                .target(name: "VHDLMachineTransformations"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "VHDLMachineTransformationsTests",
            dependencies: ["VHDLMachineTransformations", "VHDLParsing", "VHDLMachines", "JavascriptModel"]
        )
    ]
)
