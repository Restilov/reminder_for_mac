import Foundation

enum Paths {
    static var appSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("AlarmForMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var alarmsFile: URL {
        appSupportDirectory.appendingPathComponent("alarms.json")
    }

    static var settingsFile: URL {
        appSupportDirectory.appendingPathComponent("settings.json")
    }
}
