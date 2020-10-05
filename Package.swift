// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ScrollingSegmentedControl",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ScrollingSegmentedControl", targets: ["ScrollingSegmentedControl"])
    ],
    targets: [
        .target(name: "ScrollingSegmentedControl", dependencies: [])
    ]
)
