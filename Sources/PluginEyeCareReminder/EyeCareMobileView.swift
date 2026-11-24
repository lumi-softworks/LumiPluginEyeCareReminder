import SwiftUI

/// iOS 整页视图：由插件插入移动端标签页，不复用菜单栏弹窗。
struct EyeCareMobileView: View {
    let accessibilityIdentifierPrefix: String

    @State private var manager = EyeCareReminderManager.shared

    private let tint = Color.green

    private static let startTitle = String(localized: "Start", table: "EyeCareReminder", bundle: .module)
    private static let stopTitle = String(localized: "Stop", table: "EyeCareReminder", bundle: .module)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusCard
            actionButton
            intervalSection
        }
        .accessibilityIdentifier("\(accessibilityIdentifierPrefix).mobile")
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "eye.fill")
                    .font(.title2)
                    .foregroundStyle(tint)
                Text("Eye Care", tableName: "EyeCareReminder", bundle: .module)
                    .font(.headline)
                Spacer()
            }

            if manager.isActive {
                if let nextBreak = manager.nextBreakTime {
                    countdown(to: nextBreak)
                }
                Label(
                    String(
                        format: String(localized: "Today: %lld breaks", table: "EyeCareReminder", bundle: .module),
                        manager.todayBreakCount
                    ),
                    systemImage: "checkmark.circle.fill"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            } else {
                Label {
                    Text("Break reminder is off", tableName: "EyeCareReminder", bundle: .module)
                } icon: {
                    Image(systemName: "zzz")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var actionButton: some View {
        Button {
            if manager.isActive {
                manager.stop()
            } else {
                manager.start()
            }
        } label: {
            Label(
                manager.isActive ? Self.stopTitle : Self.startTitle,
                systemImage: manager.isActive ? "stop.fill" : "play.fill"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(manager.isActive ? .red : tint)
        .accessibilityIdentifier("\(accessibilityIdentifierPrefix).mobile.toggle")
    }

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interval", tableName: "EyeCareReminder", bundle: .module)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(manager.availableIntervals) { option in
                        intervalChip(option)
                    }
                }
            }
        }
    }

    private func intervalChip(_ option: EyeCareReminderManager.IntervalOption) -> some View {
        let isSelected = manager.selectedInterval == option.timeInterval
        return Button {
            manager.updateInterval(option.timeInterval)
        } label: {
            Text(option.displayName)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? tint : .primary)
                .background(
                    isSelected ? tint.opacity(0.16) : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private func countdown(to nextBreak: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if nextBreak > context.date {
                let minutes = Int(nextBreak.timeIntervalSince(context.date)) / 60
                Label(countdownTitle(minutes: minutes), systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func countdownTitle(minutes: Int) -> String {
        if minutes < 1 {
            return String(localized: "Next break: less than 1 min", table: "EyeCareReminder", bundle: .module)
        }
        if minutes == 1 {
            return String(localized: "Next break: 1 min", table: "EyeCareReminder", bundle: .module)
        }
        return String(
            format: String(localized: "Next break: %lld mins", table: "EyeCareReminder", bundle: .module),
            minutes
        )
    }
}