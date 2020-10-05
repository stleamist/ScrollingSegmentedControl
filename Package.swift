// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ScrollingSegmentedControl",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "ScrollingSegmentedControl", targets: ["ScrollingSegmentedControl"])
    ],
    targets: [
        .target(name: "ScrollingSegmentedControl", dependencies: [])
    ]
)
