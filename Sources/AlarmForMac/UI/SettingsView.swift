import AppKit
import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var launchAtLoginError: String?
    @State private var recordingHotkey = false
    @State private var recordMonitor: Any?

    private var settings: Binding<AppSettings> {
        $settingsStore.settings
    }

    var body: some View {
        Form {
            Section("Görünüm 🎨") {
                LabeledContent("Varsayılan renk") {
                    ThemeSwatchPicker(selection: settings.theme, size: 24)
                }
                Text("Her alarma eklerken ayrı renk seçebilirsin; seçici her eklemeden sonra bu renge döner.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // `settings.animation` collides with the Binding's .animation() method.
                Picker("Animasyon", selection: Binding(
                    get: { settingsStore.settings.animation },
                    set: { settingsStore.settings.animation = $0 }
                )) {
                    ForEach(PopupAnimationStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
            }

            Section("Popup 💬") {
                Picker("Ekranda kalma süresi", selection: settings.popupDuration) {
                    Text("5 saniye").tag(5.0)
                    Text("15 saniye").tag(15.0)
                    Text("30 saniye").tag(30.0)
                    Text("1 dakika").tag(60.0)
                    Text("Kapatana kadar").tag(0.0)
                }
                Toggle("Ses çal", isOn: settings.soundEnabled)
                if settingsStore.settings.soundEnabled {
                    Picker("Ses", selection: settings.soundName) {
                        ForEach(AppSettings.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                }
                Button("Popup'ı Dene ✨") {
                    let test = Alarm(time: currentTimeString(), name: "deneme", emoji: "🎈")
                    AppServices.shared.presenter.show(alarm: test)
                }
            }

            Section("Kısayol ⌨️") {
                LabeledContent("Paneli aç/kapat") {
                    HStack(spacing: 8) {
                        Button(recordingHotkey
                            ? "Bir tuş kombinasyonuna bas…"
                            : (settingsStore.settings.hotkeyEnabled ? settingsStore.settings.hotkeyLabel : "Kısayol yok")
                        ) {
                            startRecordingHotkey()
                        }
                        if settingsStore.settings.hotkeyEnabled && !recordingHotkey {
                            Button("Kaldır") {
                                settingsStore.settings.hotkeyEnabled = false
                                AppServices.shared.hotkeys.apply(settingsStore.settings)
                            }
                        }
                    }
                }
                Text("Kısayol her yerden çalışır ve menü panelini açıp kapatır. En az bir değiştirici (⌘ ⌥ ⌃) içermeli; kayıt sırasında Esc iptal eder.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Sistem ⚙️") {
                Toggle("Girişte başlat (7/24 çalışma)", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        updateLaunchAtLogin(newValue)
                    }
                if let error = launchAtLoginError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Toggle("Çıkışta onay sor", isOn: settings.confirmQuit)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func startRecordingHotkey() {
        guard !recordingHotkey else { return }
        recordingHotkey = true
        recordMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            defer {
                if !recordingHotkey, let recordMonitor {
                    NSEvent.removeMonitor(recordMonitor)
                    self.recordMonitor = nil
                }
            }
            if event.keyCode == 53 { // Esc cancels recording
                recordingHotkey = false
                return nil
            }
            let modifiers = HotkeyManager.carbonModifiers(from: event.modifierFlags)
            let required = event.modifierFlags.intersection([.command, .option, .control])
            guard !required.isEmpty else { return nil } // don't swallow plain keys
            settingsStore.settings.hotkeyKeyCode = UInt32(event.keyCode)
            settingsStore.settings.hotkeyModifiers = modifiers
            settingsStore.settings.hotkeyLabel = HotkeyManager.label(for: event)
            settingsStore.settings.hotkeyEnabled = true
            AppServices.shared.hotkeys.apply(settingsStore.settings)
            recordingHotkey = false
            return nil
        }
    }

    private func updateLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLoginError = nil
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            launchAtLoginError = "Ayarlanamadı: \(error.localizedDescription)\n(Bu özellik uygulama .app olarak çalışırken kullanılabilir.)"
        }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
