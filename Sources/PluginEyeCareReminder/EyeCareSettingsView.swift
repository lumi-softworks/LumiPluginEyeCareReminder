import LumiUI
import SwiftUI

struct EyeCareSettingsView: View {
    /// 品牌配置：无障碍标识前缀由宿主注入。
    let configuration: EyeCareReminderConfiguration

    @State private var manager = EyeCareReminderManager.shared
    @State private var customMinutes: Int = 20

    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: String(localized: "Reminder Intervals", table: "EyeCareReminder", bundle: .module)) {
                VStack(spacing: 0) {
                    // 用选项自身的稳定 id 标识行，而不是数组下标——
                    // 列表会被增删并重新排序，下标变化会让 SwiftUI 把旧行
                    // 的状态套用到别的行上。
                    ForEach(manager.availableIntervals) { option in
                        AppSettingRow(
                            title: option.displayName,
                            description: EyeCareReminderManager.commonIntervals.contains(option)
                                ? nil
                                : String(localized: "Custom interval", table: "EyeCareReminder", bundle: .module),
                            icon: "eye"
                        ) {
                            if !EyeCareReminderManager.commonIntervals.contains(option) {
                                AppButton(systemImage: "minus", style: .destructive) {
                                    manager.removeInterval(option)
                                }
                                .help(Text("Delete", tableName: "EyeCareReminder", bundle: .module))
                                .accessibilityIdentifier("\(configuration.accessibilityIdentifierPrefix).interval.remove.\(Int(option.timeInterval))")
                            }
                        }
                        if option != manager.availableIntervals.last {
                            rowDivider
                        }
                    }

                    rowDivider

                    AppSettingRow(
                        title: String(localized: "Add Custom (minutes):", table: "EyeCareReminder", bundle: .module),
                        description: String(localized: "Add a custom rest reminder interval.", table: "EyeCareReminder", bundle: .module),
                        icon: "plus.circle"
                    ) {
                        HStack(spacing: 8) {
                            TextField("", value: $customMinutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .accessibilityIdentifier("\(configuration.accessibilityIdentifierPrefix).custom-interval.minutes")
                                .onSubmit { addCustomInterval() }
                            AppButton(systemImage: "plus", style: .secondary, action: addCustomInterval)
                                .disabled(customMinutes <= 0)
                                .accessibilityIdentifier("\(configuration.accessibilityIdentifierPrefix).custom-interval.add")
                        }
                    }

                    rowDivider

                    AppSettingRow(
                        title: String(localized: "Reset to Default Intervals", table: "EyeCareReminder", bundle: .module),
                        description: String(localized: "Restore the built-in reminder intervals.", table: "EyeCareReminder", bundle: .module),
                        icon: "arrow.counterclockwise"
                    ) {
                        AppButton(
                            String(localized: "Reset", table: "EyeCareReminder", bundle: .module),
                            systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            size: .small,
                            action: manager.resetIntervals
                        )
                        .accessibilityIdentifier("\(configuration.accessibilityIdentifierPrefix).interval.reset")
                    }
                }
            }
        }
        .onAppear {
            customMinutes = 20
        }
    }

    private func addCustomInterval() {
        guard customMinutes > 0 else { return }
        manager.addCustomInterval(minutes: customMinutes)
        customMinutes = 20 // Reset to default suggestion
    }

    /// iOS 的卡片行自带发丝分隔线；macOS 的分组卡片需要显式分隔线。
    @ViewBuilder
    private var rowDivider: some View {
        #if os(macOS)
        Divider()
            .padding(.vertical, 8)
        #endif
    }
}

#Preview {
    EyeCareSettingsView(configuration: EyeCareReminderConfiguration())
        .frame(width: 400, height: 300)
}
