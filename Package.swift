// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TraceLogger",
    products: [
        .library(name: "TraceLogger", targets: ["TraceLogger"]),
    ],
    dependencies: [
        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.1.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TraceLogger",
            dependencies: ["Logging", "Service"]
        ),
        .testTarget(
            name: "TraceLoggerTests",
            dependencies: ["TraceLogger"]
        )
    ]
)
