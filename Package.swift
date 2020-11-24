// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MGSwipeTableCell",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "MGSwipeTableCell",
            targets: ["MGSwipeTableCell"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MGSwipeTableCell",
            path: "MGSwipeTableCell",
            exclude: [
                "Info.plist",
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]
        ),
    ]
)
