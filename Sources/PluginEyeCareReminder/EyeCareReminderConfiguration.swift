import Foundation

/// 护眼提醒插件的品牌配置。
///
/// 共享包不能把宿主品牌写死在代码里：插件 id、logger subsystem 与
/// 无障碍标识前缀都属于「谁的插件」，必须由宿主在装配时注入。
///
/// - `pluginID`：插件唯一标识。宿主必须传入自己的历史 id，否则会丢失
///   用户已保存的启用状态与插件专属数据目录（见 README 的「历史兼容」）。
/// - `loggerSubsystem`：日志子系统。宿主的磁盘日志插件按 subsystem 前缀
///   收集日志，写错会让插件日志无法落盘。
/// - `accessibilityIdentifierPrefix`：设置页控件的无障碍标识前缀，
///   UI 测试按它定位控件。
public struct EyeCareReminderConfiguration: Sendable {
    /// Lumi 品牌的默认插件标识。
    public static let defaultPluginID = "com.coffic.lumi.plugin.eye-care"

    /// Lumi 品牌的默认日志子系统。
    public static let defaultLoggerSubsystem = "com.coffic.lumi.plugin.eye-care"

    /// 插件唯一标识。
    public let pluginID: String

    /// 日志子系统。
    public let loggerSubsystem: String

    /// 设置页控件的无障碍标识前缀。
    public let accessibilityIdentifierPrefix: String

    public init(
        pluginID: String = EyeCareReminderConfiguration.defaultPluginID,
        loggerSubsystem: String = EyeCareReminderConfiguration.defaultLoggerSubsystem,
        accessibilityIdentifierPrefix: String = "eyecare"
    ) {
        self.pluginID = pluginID
        self.loggerSubsystem = loggerSubsystem
        self.accessibilityIdentifierPrefix = accessibilityIdentifierPrefix
    }
}
