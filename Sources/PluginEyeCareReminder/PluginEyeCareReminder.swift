import KernelCore
import OSLog
import ProviderDocsView
import ProviderMenuBar
import ProviderStorage
import ProviderSettingView
import SwiftUI

/// Eye Care Reminder Plugin: reminds users to take eye care breaks.
///
/// 共享远程包：宿主（Lumi / Wakey / …）在装配时注入自己的品牌配置，
/// 插件本身不写死任何宿主品牌信息。
@MainActor
public final class PluginEyeCareReminder: SuperPlugin {
    /// 品牌配置（插件 id、日志子系统、无障碍标识前缀）。
    public let configuration: EyeCareReminderConfiguration

    /// 日志子系统跟随宿主注入的子系统，便于宿主在系统日志中区分品牌。
    nonisolated let logger: Logger

    public let id: String
    public let order: Int
    public let metadata: PluginMetadata

    /// - Parameters:
    ///   - configuration: 品牌配置。宿主必须传入自己的历史 id，
    ///     否则会丢失用户已保存的启用状态与插件专属数据目录。
    ///   - order: 插件启动顺序（数值越小越先启动）。
    ///   - policy: 启用策略。
    public init(
        configuration: EyeCareReminderConfiguration = EyeCareReminderConfiguration(),
        order: Int = 8,
        policy: PluginEnablePolicy = .enabledByDefault
    ) {
        self.configuration = configuration
        self.id = configuration.pluginID
        self.order = order
        self.metadata = PluginMetadata(
            id: configuration.pluginID,
            name: String(localized: "Eye Care", table: "EyeCareReminder", bundle: .module, comment: "Name of the eye care reminder plugin"),
            description: String(localized: "Remind you to rest your eyes every 20 minutes", table: "EyeCareReminder", bundle: .module, comment: "Description of what the Eye Care Reminder plugin does"),
            version: "1.0.0",
            category: .general,
            stage: .stable,
            policy: policy
        )
        self.logger = Logger(subsystem: configuration.loggerSubsystem, category: "EyeCareReminder")
    }

    public func onBoot(kernel: KernelCoreContainer) throws {
        // 说明书条目：设置页「通用 → 说明书」中展示
        kernel.resolveProvider((any DocsViewProviding).self)?
            .addManual(DocsEntry(id: id, name: metadata.name) {
                EyeCareManualView()
            })

        // 按 CofficLab 存储规范，插件状态落盘在宿主分配的插件专属目录
        // （Binary Plist），而不是 UserDefaults。
        if let storage = kernel.resolveProvider((any StorageProviding).self) {
            EyeCareReminderManager.shared.attachStateStore(directory: storage.pluginDataDirectory(for: id))
        }

        try contributeMenuBar(to: kernel)

        // 设置页标签
        kernel.resolveProvider((any SettingViewProviding).self)?
            .addEntries([
                SettingEntryItem(
                    id: id,
                    title: String(localized: "Eye Care", table: "EyeCareReminder", bundle: .module, comment: "Name of the eye care reminder plugin"),
                    systemImage: "eye.fill",
                    detail: { EyeCareSettingsView(configuration: self.configuration) }
                )
            ])
    }

    public func onEnable(kernel: KernelCoreContainer) async throws {
        try contributeMenuBar(to: kernel)
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any DocsViewProviding).self)?.removeEntries(id: id)
        kernel.resolveProvider((any SettingViewProviding).self)?.removeEntries(ids: [id])

        // 清理：卸载插件时停止提醒定时器
        EyeCareReminderManager.shared.stop()
    }

    private func contributeMenuBar(to kernel: KernelCoreContainer) throws {
        guard let menuBar = kernel.resolveProvider(MenuBarProviding.self) else { return }
        let ownerID = id
        try kernel.trackContribution {
            menuBar.removeItems(ownedBy: ownerID)
        }
        menuBar.addPopup(MenuBarContribution(
            id: "\(id).popup",
            title: metadata.name,
            order: order,
            ownerPluginID: id
        ) {
            EyeCareReminderPopupView()
        })
    }
}
