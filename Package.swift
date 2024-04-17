// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package definition.
let package = Package(
    name: "LLFSMGenerate",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other
        // packages.
        .executable(
            name: "llfsmgenerate",
            targets: ["MachineGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/mipalgu/VHDLMachines", from: "4.0.0"),
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "2.4.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/mipalgu/VHDLKripkeStructureGenerator.git", from: "0.2.2"),
        .package(url: "https://github.com/CPSLabGU/SwiftUtils.git", from: "0.1.0"),
        .package(url: "https://github.com/CPSLabGU/VHDLJSModels", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "MachineGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                .product(name: "VHDLJSModels", package: "VHDLJSModels")
            ]
        ),
        .testTarget(
            name: "MachineGeneratorTests",
            dependencies: [
                .target(name: "MachineGenerator"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                .product(name: "VHDLJSModels", package: "VHDLJSModels"),
                "TestHelpers"
            ]
        ),
        .testTarget(
            name: "TestHelpers",
            dependencies: [
                .product(name: "VHDLJSModels", package: "VHDLJSModels"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing")
            ]
        )
    ]
)
