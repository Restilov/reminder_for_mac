import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar app: runs in the background without appearing in the Dock;
        // temporarily shows in the Dock when the main window opens.
        NSApp.setActivationPolicy(.accessory)

        DebugLog.log("app started, screens: \(NSScreen.screens.map(\.frame))")
        AppServices.shared.scheduler.start()

        AppServices.shared.hotkeys.onHotkey = { MenuPanelToggler.toggle() }
        AppServices.shared.hotkeys.apply(AppServices.shared.settingsStore.settings)

        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main
        ) { note in
            guard let window = note.object as? NSWindow, Self.isStandardWindow(window) else { return }
            NSApp.setActivationPolicy(.regular)
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification, object: nil, queue: .main
        ) { note in
            guard let window = note.object as? NSWindow, Self.isStandardWindow(window) else { return }
            DispatchQueue.main.async {
                let anyVisible = NSApp.windows.contains {
                    Self.isStandardWindow($0) && $0.isVisible
                }
                if !anyVisible {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }
    }

    /// Titled windows like the main window / settings; excludes popup panels
    /// and the menu bar panel.
    private static func isStandardWindow(_ window: NSWindow) -> Bool {
        !(window is NSPanel) && window.styleMask.contains(.titled)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
