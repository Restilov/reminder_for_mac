import Foundation

final class AppServices {
    static let shared = AppServices()

    let store: ReminderStore
    let settingsStore: SettingsStore
    let presenter: PopupPresenter
    let scheduler: ReminderScheduler
    let hotkeys = HotkeyManager()

    private init() {
        let store = ReminderStore()
        let settingsStore = SettingsStore()
        let presenter = PopupPresenter(settingsStore: settingsStore)
        self.store = store
        self.settingsStore = settingsStore
        self.presenter = presenter
        self.scheduler = ReminderScheduler(store: store) { reminder in
            presenter.show(reminder: reminder)
        }
    }
}
