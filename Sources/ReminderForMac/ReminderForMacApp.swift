import SwiftUI

@main
struct ReminderForMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("My Reminders", systemImage: "alarm.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)

        Window("My Reminders", id: "main") {
            MainWindowView()
        }
        .defaultSize(width: 480, height: 520)

        Settings {
            SettingsView()
        }
    }
}
