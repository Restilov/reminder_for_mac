import Foundation

final class AppServices {
    static let shared = AppServices()

    let store: AlarmStore
    let settingsStore: SettingsStore
    let presenter: PopupPresenter
    let scheduler: AlarmScheduler
    let hotkeys = HotkeyManager()

    private init() {
        let store = AlarmStore()
        let settingsStore = SettingsStore()
        let presenter = PopupPresenter(settingsStore: settingsStore)
        self.store = store
        self.settingsStore = settingsStore
        self.presenter = presenter
        self.scheduler = AlarmScheduler(store: store) { alarm in
            presenter.show(alarm: alarm)
        }
    }
}
