import SwiftUI

@main
struct AlarmForMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Alarmlarım", systemImage: "alarm.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)

        Window("Alarmlarım", id: "main") {
            MainWindowView()
        }
        .defaultSize(width: 480, height: 520)

        Settings {
            SettingsView()
        }
    }
}
