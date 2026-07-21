import AppKit
import Foundation

/// Sets a one-shot Timer for the next active reminder; when it fires, the reminder is
/// disabled (since it's one-shot) and the timer is re-armed for the next one. Catches
/// missed reminders when the Mac wakes from sleep or the system clock changes.
final class ReminderScheduler {
    private let store: ReminderStore
    private let onFire: (Reminder) -> Void

    private var timer: Timer?
    private var scheduledDate: Date?
    private var suspended = false

    init(store: ReminderStore, onFire: @escaping (Reminder) -> Void) {
        self.store = store
        self.onFire = onFire
    }

    func start() {
        store.onChange = { [weak self] in self?.reschedule() }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.handleWake()
        }
        NotificationCenter.default.addObserver(
            forName: .NSSystemClockDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.reschedule()
        }

        reschedule()
    }

    func reschedule() {
        guard !suspended else { return }
        timer?.invalidate()
        timer = nil
        scheduledDate = nil

        let now = Date()
        let next = store.reminders
            .filter { $0.enabled }
            .compactMap { $0.nextFireDate(after: now) }
            .min()
        guard let fireDate = next else { return }

        scheduledDate = fireDate
        let timer = Timer(fire: fireDate, interval: 0, repeats: false) { [weak self] _ in
            self?.fireDue()
        }
        timer.tolerance = 0.5
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// When the scheduled time arrives (or has passed after sleep), fires all reminders
    /// for that minute — including ones missed during sleep.
    private func fireDue() {
        guard let scheduled = scheduledDate else {
            reschedule()
            return
        }
        let reference = scheduled.addingTimeInterval(-2)
        let deadline = Date().addingTimeInterval(2)

        suspended = true
        for reminder in store.reminders where reminder.enabled {
            if let next = reminder.nextFireDate(after: reference), next <= deadline {
                onFire(reminder)
                store.setEnabled(reminder.id, false)
            }
        }
        suspended = false
        reschedule()
    }

    private func handleWake() {
        if let scheduled = scheduledDate, scheduled <= Date() {
            fireDue()
        } else {
            reschedule()
        }
    }
}
