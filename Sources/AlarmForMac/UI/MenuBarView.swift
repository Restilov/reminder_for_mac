import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var store = AppServices.shared.store
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("⏰ Alarmlarım")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

            Divider()

            if store.alarms.isEmpty {
                Text("Henüz alarm yok 💤\nAşağıdan ilk alarmını ekle!")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(store.alarms) { alarm in
                            AlarmRow(alarm: alarm, compact: true)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .frame(maxHeight: 240)
            }

            Divider()

            AddAlarmForm(compact: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            Divider()

            HStack {
                Button("Pencereyi Aç") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Button("Ayarlar") {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Çıkış") {
                    QuitConfirm.requestQuit(settingsStore: settingsStore)
                }
            }
            .controlSize(.small)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
    }
}

/// Alarm row shared between the menu panel and the main window.
struct AlarmRow: View {
    let alarm: Alarm
    var compact = false

    @ObservedObject private var store = AppServices.shared.store
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill((alarm.theme ?? settingsStore.settings.theme).gradient)
                .frame(width: compact ? 10 : 14, height: compact ? 10 : 14)
            Text(alarm.emoji)
                .font(.system(size: compact ? 16 : 22))
            Text(alarm.time)
                .font(.system(size: compact ? 14 : 18, weight: .bold, design: .monospaced))
                .foregroundStyle(alarm.enabled ? .primary : .secondary)
            Text(alarm.name)
                .font(.system(size: compact ? 13 : 15, design: .rounded))
                .foregroundStyle(alarm.enabled ? .primary : .secondary)
                .lineLimit(1)
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.enabled },
                set: { store.setEnabled(alarm.id, $0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)
            Button {
                store.remove(id: alarm.id)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Alarmı sil")
        }
        .padding(.horizontal, compact ? 6 : 10)
        .padding(.vertical, compact ? 4 : 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary.opacity(0.04))
        )
    }
}
