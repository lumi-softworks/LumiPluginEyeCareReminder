import SwiftUI
internal import Combine

/// Eye care reminder status information
struct EyeCareReminderStatusInfo: View {
    @State private var manager = EyeCareReminderManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if manager.isActive {
                if let nextBreak = manager.nextBreakTime {
                    NextBreakCountdown(nextBreak: nextBreak)
                }

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.green)

                    Text(String(format: String(localized: "Today: %lld breaks", table: "EyeCareReminder", bundle: .module), manager.todayBreakCount))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "zzz")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text("Break reminder is off", tableName: "EyeCareReminder", bundle: .module)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

/// 「下一次休息」倒计时。
///
/// 用 `TimelineView` 按分钟刷新：`Timer.publish` 在视图因提醒重排而频繁
/// 重建时会失效，`now` 停在创建时刻，倒计时会越显示越长。
private struct NextBreakCountdown: View {
    let nextBreak: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if nextBreak > context.date {
                let minutes = Int(nextBreak.timeIntervalSince(context.date)) / 60
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Group {
                        if minutes < 1 {
                            Text("Next break: less than 1 min", tableName: "EyeCareReminder", bundle: .module)
                        } else if minutes == 1 {
                            Text("Next break: 1 min", tableName: "EyeCareReminder", bundle: .module)
                        } else {
                            Text(String(format: String(localized: "Next break: %lld mins", table: "EyeCareReminder", bundle: .module), minutes))
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
    }
}
