import Foundation

struct ImportResult {
    var added: Int = 0
    var skipped: Int = 0
}

final class AlarmStore: ObservableObject {
    @Published private(set) var alarms: [Alarm] = []

    /// Hook to re-arm the scheduler on changes.
    var onChange: (() -> Void)?

    private let fileURL: URL

    init(fileURL: URL = Paths.alarmsFile) {
        self.fileURL = fileURL
        load()
    }

    func add(time: String, name: String, emoji: String, theme: PopupTheme? = nil) {
        guard let normalized = Alarm.normalizedTime(time) else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespaces)
        let alarm = Alarm(
            time: normalized,
            name: trimmedName.isEmpty ? "Alarm" : trimmedName,
            emoji: trimmedEmoji.isEmpty ? "⏰" : trimmedEmoji,
            theme: theme
        )
        mutate { $0.append(alarm) }
    }

    func remove(id: UUID) {
        mutate { $0.removeAll { $0.id == id } }
    }

    func setEnabled(_ id: UUID, _ enabled: Bool) {
        mutate {
            guard let index = $0.firstIndex(where: { $0.id == id }) else { return }
            $0[index].enabled = enabled
        }
    }

    /// Accepts both `[{"time":"23:00","name":"sleep"}]` and `{"alarms":[...]}` formats.
    func importJSON(from url: URL) -> ImportResult {
        struct Wrapper: Codable { var alarms: [Alarm] }

        guard let data = try? Data(contentsOf: url) else {
            return ImportResult(added: 0, skipped: 0)
        }
        let decoder = JSONDecoder()
        var incoming: [Alarm] = []
        if let list = try? decoder.decode([Alarm].self, from: data) {
            incoming = list
        } else if let wrapper = try? decoder.decode(Wrapper.self, from: data) {
            incoming = wrapper.alarms
        }

        var result = ImportResult()
        var valid: [Alarm] = []
        for var alarm in incoming {
            if let normalized = Alarm.normalizedTime(alarm.time) {
                alarm.time = normalized
                alarm.id = UUID()
                valid.append(alarm)
                result.added += 1
            } else {
                result.skipped += 1
            }
        }
        if !valid.isEmpty {
            mutate { $0.append(contentsOf: valid) }
        }
        return result
    }

    private func mutate(_ block: (inout [Alarm]) -> Void) {
        var copy = alarms
        block(&copy)
        copy.sort { ($0.time, $0.name) < ($1.time, $1.name) }
        alarms = copy
        persist()
        onChange?()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([Alarm].self, from: data) else { return }
        alarms = loaded.sorted { ($0.time, $0.name) < ($1.time, $1.name) }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(alarms) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
