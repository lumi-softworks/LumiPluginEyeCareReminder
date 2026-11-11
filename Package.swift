// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LumiPluginEyeCareReminder",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "PluginEyeCareReminder",
            targets: ["PluginEyeCareReminder"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/lumi-softworks/LumiKitReminder.git", from: "1.0.1"),
        .package(url: "https://github.com/lumi-softworks/LumiLogging.git", from: "1.0.1"),
        .package(url: "https://github.com/lumi-softworks/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/lumi-softworks/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/lumi-softworks/LumiUI.git", from: "1.13.1"),
        .package(url: "https://github.com/lumi-softworks/LumiProviders.git", from: "1.22.0")
    ],
    targets: [
        .target(
            name: "PluginEyeCareReminder",
            dependencies: [
                .product(name: "KitReminder", package: "LumiKitReminder"),
                .product(name: "LumiLoggingKit", package: "LumiLogging"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
                .product(name: "ProviderStorage", package: "LumiProviders"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "LumiUI", package: "LumiUI")
            ],
            path: "Sources/PluginEyeCareReminder",
            resources: [.process("../../Resources/EyeCareReminder.xcstrings")]
        ),
        .testTarget(
            name: "PluginEyeCareReminderTests",
            dependencies: [
                "PluginEyeCareReminder",
                .product(name: "KitReminder", package: "LumiKitReminder"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
                .product(name: "ProviderSettingView", package: "LumiSettings")
            ],
            path: "Tests/PluginEyeCareReminderTests"
        )
    ]
)
