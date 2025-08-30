// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Toki", // or "Toki"
    platforms: [
        .macOS(.v13) // match your code, since you’re already using macOS 13 APIs
    ],
    products: [
        .executable(
            name: "toki", // the CLI name (binary in .build/release)
            targets: ["Toki"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.0" // much newer than 0.0.4
        )
    ],
    targets: [
        .executableTarget(
            name: "Toki",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
