import Foundation

struct ImportResult {
    var added: Int = 0
    var skipped: Int = 0
}

final class ReminderStore: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []

    /// Hook to re-arm the scheduler on changes.
    var onChange: (() -> Void)?

    private let fileURL: URL

    init(fileURL: URL = Paths.remindersFile) {
        self.fileURL = fileURL
        load()
    }

    func add(time: String, name: String, emoji: String, theme: PopupTheme? = nil) {
        guard let normalized = Reminder.normalizedTime(time) else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespaces)
        let reminder = Reminder(
            time: normalized,
            name: trimmedName.isEmpty ? "Reminder" : trimmedName,
            emoji: trimmedEmoji.isEmpty ? "⏰" : trimmedEmoji,
            theme: theme
        )
        mutate { $0.append(reminder) }
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

    /// Accepts both `[{"time":"23:00","name":"sleep"}]` and `{"reminders":[...]}` formats.
    func importJSON(from url: URL) -> ImportResult {
        struct Wrapper: Codable { var reminders: [Reminder] }

        guard let data = try? Data(contentsOf: url) else {
            return ImportResult(added: 0, skipped: 0)
        }
        let decoder = JSONDecoder()
        var incoming: [Reminder] = []
        if let list = try? decoder.decode([Reminder].self, from: data) {
            incoming = list
        } else if let wrapper = try? decoder.decode(Wrapper.self, from: data) {
            incoming = wrapper.reminders
        }

        var result = ImportResult()
        var valid: [Reminder] = []
        for var reminder in incoming {
            if let normalized = Reminder.normalizedTime(reminder.time) {
                reminder.time = normalized
                reminder.id = UUID()
                valid.append(reminder)
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

    private func mutate(_ block: (inout [Reminder]) -> Void) {
        var copy = reminders
        block(&copy)
        copy.sort { ($0.time, $0.name) < ($1.time, $1.name) }
        reminders = copy
        persist()
        onChange?()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([Reminder].self, from: data) else { return }
        reminders = loaded.sorted { ($0.time, $0.name) < ($1.time, $1.name) }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(reminders) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
