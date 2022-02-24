// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bitski-iOS-SDK",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Bitski-iOS-SDK",
            targets: ["Bitski-iOS-SDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Web3",
                 url: "https://github.com/Boilertalk/Web3.swift",
                 from: "0.5.0"),
        .package(name: "AppAuth",url: "https://github.com/openid/AppAuth-iOS.git", .upToNextMajor(from: "1.3.0")),
        .package(name: "secp256k1",url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.4"),
        .package(name: "OHHTTPStubs",url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Bitski-iOS-SDK",
            dependencies: [
                .product(name: "Web3", package: "Web3"),
                .product(name: "Web3PromiseKit", package: "Web3"),
                .product(name: "Web3ContractABI", package: "Web3"),
                .product(name: "AppAuth", package: "AppAuth")
            ],
            resources: [
              .copy("WKWebView/BitskiWeb3Provider.js"),
            ]),
        .testTarget(
            name: "Bitski-iOS-SDKTests",
            dependencies: [
                "Bitski-iOS-SDK",
                .product(name: "Web3", package: "Web3"),
                .product(name: "Web3PromiseKit", package: "Web3"),
                .product(name: "Web3ContractABI", package: "Web3"),
                .product(name: "AppAuth", package: "AppAuth"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ]),
    ]
)
