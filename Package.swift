// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Windows)
/// The executable target.
let executableTarget = PackageDescription.Target.executableTarget(
    name: "MachineGenerator",
    dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "VHDLMachines", package: "VHDLMachines"),
        .product(name: "VHDLParsing", package: "VHDLParsing"),
        .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
        .product(name: "SwiftUtils", package: "SwiftUtils"),
        .product(name: "VHDLJSModels", package: "VHDLJSModels"),
        .product(name: "VHDLKripkeStructures", package: "VHDLKripkeStructures"),
        .target(name: "GeneratorCommands")
    ],
    swiftSettings: [.unsafeFlags(["-parse-as-library"])]
)
#else
/// The executable target.
let executableTarget = PackageDescription.Target.executableTarget(
    name: "MachineGenerator",
    dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "VHDLMachines", package: "VHDLMachines"),
        .product(name: "VHDLParsing", package: "VHDLParsing"),
        .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
        .product(name: "SwiftUtils", package: "SwiftUtils"),
        .product(name: "VHDLJSModels", package: "VHDLJSModels"),
        .product(name: "VHDLKripkeStructures", package: "VHDLKripkeStructures"),
        .target(name: "GeneratorCommands")
    ]
)
#endif

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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.2"),
        .package(url: "https://github.com/mipalgu/VHDLMachines", from: "4.0.3"),
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "2.7.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(name: "VHDLKripkeStructureGenerator", path: "../../mipalgu/VHDLKripkeStructureGenerator"),
        .package(url: "https://github.com/CPSLabGU/SwiftUtils.git", from: "0.1.0"),
        .package(url: "https://github.com/CPSLabGU/VHDLJSModels", from: "1.0.0"),
        .package(url: "https://github.com/CPSLabGU/VHDLKripkeStructures", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        executableTarget,
        .target(
            name: "GeneratorCommands",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                .product(name: "VHDLJSModels", package: "VHDLJSModels"),
                .product(name: "VHDLKripkeStructures", package: "VHDLKripkeStructures")
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-Xfrontend", "-entry-point-function-name", "-Xfrontend", "wWinMain"],
                    .when(platforms: [.windows])
                )
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                .target(name: "GeneratorCommands"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "VHDLKripkeStructureGenerator", package: "VHDLKripkeStructureGenerator"),
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                .product(name: "VHDLJSModels", package: "VHDLJSModels"),
                "TestHelpers",
                .product(name: "VHDLKripkeStructures", package: "VHDLKripkeStructures")
            ]
        ),
        .testTarget(
            name: "TestHelpers",
            dependencies: [
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "VHDLJSModels", package: "VHDLJSModels"),
                .product(name: "VHDLKripkeStructures", package: "VHDLKripkeStructures")
            ]
        )
    ]
)
