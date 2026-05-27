// swift-tools-version: 5.10
//
// 这个文件是 Swift Package Manager 的项目配置。
// 你可以把它理解成“项目说明书”：告诉 Swift 编译器这个 App 叫什么、
// 支持哪个 macOS 版本，以及源代码放在哪里。

import PackageDescription

let package = Package(
    name: "WangZheFarmAssistant",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "WangZheFarmAssistant",
            targets: ["WangZheFarmAssistantApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WangZheFarmAssistantApp",
            path: "Sources/WangZheFarmAssistantApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
