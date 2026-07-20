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
            Section("Appearance 🎨") {
                LabeledContent("Default color") {
                    ThemeSwatchPicker(selection: settings.theme, size: 24)
                }
                Text("You can pick a separate color for each alarm; the picker resets to this color after every add.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // `settings.animation` collides with the Binding's .animation() method.
                Picker("Animation", selection: Binding(
                    get: { settingsStore.settings.animation },
                    set: { settingsStore.settings.animation = $0 }
                )) {
                    ForEach(PopupAnimationStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
            }

            Section("Popup 💬") {
                Picker("On-screen duration", selection: settings.popupDuration) {
                    Text("5 seconds").tag(5.0)
                    Text("15 seconds").tag(15.0)
                    Text("30 seconds").tag(30.0)
                    Text("1 minute").tag(60.0)
                    Text("Until dismissed").tag(0.0)
                }
                Toggle("Play sound", isOn: settings.soundEnabled)
                if settingsStore.settings.soundEnabled {
                    Picker("Sound", selection: settings.soundName) {
                        ForEach(AppSettings.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                }
                Button("Try Popup ✨") {
                    let test = Alarm(time: currentTimeString(), name: "test", emoji: "🎈")
                    AppServices.shared.presenter.show(alarm: test)
                }
            }

            Section("Shortcut ⌨️") {
                LabeledContent("Toggle panel") {
                    HStack(spacing: 8) {
                        Button(recordingHotkey
                            ? "Press a key combination…"
                            : (settingsStore.settings.hotkeyEnabled ? settingsStore.settings.hotkeyLabel : "No shortcut")
                        ) {
                            startRecordingHotkey()
                        }
                        if settingsStore.settings.hotkeyEnabled && !recordingHotkey {
                            Button("Remove") {
                                settingsStore.settings.hotkeyEnabled = false
                                AppServices.shared.hotkeys.apply(settingsStore.settings)
                            }
                        }
                    }
                }
                Text("The shortcut works from anywhere and toggles the menu panel. It must include at least one modifier (⌘ ⌥ ⌃); press Esc to cancel while recording.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("System ⚙️") {
                Toggle("Launch at login (24/7 operation)", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        updateLaunchAtLogin(newValue)
                    }
                if let error = launchAtLoginError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Toggle("Ask for confirmation on quit", isOn: settings.confirmQuit)
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
            launchAtLoginError = "Couldn't set it: \(error.localizedDescription)\n(This feature is available when the app runs as a .app.)"
        }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
