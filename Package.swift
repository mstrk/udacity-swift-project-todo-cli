// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TodoApp",
    products: [
        .executable(name: "TodoApp", targets: ["TodoApp"]),
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .target(
            name: "TodoApp",
            dependencies: []),
        .testTarget(
            name: "TodoAppTests",
            dependencies: ["TodoApp"]),
    ]
)
