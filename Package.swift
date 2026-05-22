// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacCap",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "MacCap", targets: ["MacCapApp"]),
    ],
    targets: [
        .executableTarget(
            name: "MacCapApp",
            dependencies: [
                "MacCapFeatureRecording",
            ],
            path: "Sources/MacCapApp"
        ),
        .target(
            name: "MacCapFeatureRecording",
            dependencies: [
                "MacCapDomain",
                "MacCapInfrastructureCapture",
            ],
            path: "Sources/MacCapFeatureRecording"
        ),
        .target(
            name: "MacCapDomain",
            path: "Sources/MacCapDomain"
        ),
        .target(
            name: "MacCapInfrastructureCapture",
            dependencies: [
                "MacCapDomain",
            ],
            path: "Sources/MacCapInfrastructureCapture"
        ),
    ]
)
