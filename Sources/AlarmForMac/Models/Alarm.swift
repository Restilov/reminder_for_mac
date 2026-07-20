import Foundation

struct Alarm: Identifiable, Equatable {
    var id: UUID = UUID()
    var time: String // "HH:mm"
    var name: String
    var emoji: String = "⏰"
    var enabled: Bool = true
    /// Per-alarm popup color; if nil, the default from settings is used.
    var theme: PopupTheme?

    static func isValidTime(_ raw: String) -> Bool {
        normalizedTime(raw) != nil
    }

    /// Normalizes inputs like "9:5" / "09:05" to "09:05" format; nil if invalid.
    static func normalizedTime(_ raw: String) -> String? {
        let parts = raw.trimmingCharacters(in: .whitespaces).split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0...23).contains(hour), (0...59).contains(minute) else { return nil }
        return String(format: "%02d:%02d", hour, minute)
    }

    var hourMinute: (hour: Int, minute: Int)? {
        guard let normalized = Alarm.normalizedTime(time) else { return nil }
        let parts = normalized.split(separator: ":")
        return (Int(parts[0])!, Int(parts[1])!)
    }

    /// The first fire time after the given date (today or tomorrow).
    func nextFireDate(after date: Date = Date()) -> Date? {
        guard let hm = hourMinute else { return nil }
        var components = DateComponents()
        components.hour = hm.hour
        components.minute = hm.minute
        components.second = 0
        return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }
}

extension Alarm: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, time, name, emoji, enabled, theme
    }

    // Imported JSON may be missing the id/emoji/enabled/theme fields.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        time = try container.decode(String.self, forKey: .time)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Alarm"
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "⏰"
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        theme = (try? container.decodeIfPresent(PopupTheme.self, forKey: .theme)) ?? nil
    }
}
