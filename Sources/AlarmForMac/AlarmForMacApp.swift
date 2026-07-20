import SwiftUI

@main
struct AlarmForMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("My Alarms", systemImage: "alarm.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)

        Window("My Alarms", id: "main") {
            MainWindowView()
        }
        .defaultSize(width: 480, height: 520)

        Settings {
            SettingsView()
        }
    }
}
