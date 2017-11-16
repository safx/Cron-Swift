// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Cron",
    products: [
       .library(
           name: "Cron",
           targets: ["Cron"]),
    ],
    dependencies: [
    ],
    targets: [
       .target(
           name: "Cron",
           dependencies: []),
    ]
)
