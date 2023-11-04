// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Todotxt",
  defaultLocalization: "en",
  platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9)],
  products: [
    .library(
      name: "Todotxt",
      targets: ["Todotxt"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-markdown", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "Todotxt",
      dependencies: ["Builder", "Object"]),
    .target(
      name: "Builder",
      dependencies: ["Object", .product(name: "Markdown", package: "swift-markdown")]),
    .target(
      name: "Object"),
    .testTarget(
      name: "TodotxtTests",
      dependencies: ["Todotxt"]),
  ]
)
