import Foundation

enum Paths {
    static var appSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("ReminderForMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var remindersFile: URL {
        appSupportDirectory.appendingPathComponent("reminders.json")
    }

    static var settingsFile: URL {
        appSupportDirectory.appendingPathComponent("settings.json")
    }
}
