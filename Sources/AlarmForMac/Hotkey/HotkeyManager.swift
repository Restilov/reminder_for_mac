import AppKit
import Carbon.HIToolbox

/// Manages the system-wide hotkey (works even when the app is in the background).
/// Uses Carbon RegisterEventHotKey; requires no special permission.
final class HotkeyManager {
    var onHotkey: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    func apply(_ settings: AppSettings) {
        if settings.hotkeyEnabled {
            register(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers)
        } else {
            unregister()
        }
    }

    private func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()
        installHandlerIfNeeded()
        let hotKeyID = EventHotKeyID(signature: OSType(0x414C_524D), id: 1) // 'ALRM'
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    private func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRef = nil
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async { manager.onHotkey?() }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerRef
        )
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        if flags.contains(.option) { mods |= UInt32(optionKey) }
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        if flags.contains(.shift) { mods |= UInt32(shiftKey) }
        return mods
    }

    static func label(for event: NSEvent) -> String {
        var text = ""
        let flags = event.modifierFlags
        if flags.contains(.control) { text += "⌃" }
        if flags.contains(.option) { text += "⌥" }
        if flags.contains(.shift) { text += "⇧" }
        if flags.contains(.command) { text += "⌘" }
        text += keyName(for: event)
        return text
    }

    private static func keyName(for event: NSEvent) -> String {
        switch Int(event.keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        default:
            return event.charactersIgnoringModifiers?.uppercased() ?? "?"
        }
    }
}

/// Programmatically toggles the panel of the ⏰ menu bar icon.
/// Since MenuBarExtra offers no direct API, a click is sent to the status bar button.
enum MenuPanelToggler {
    static func toggle() {
        guard let button = statusBarButton() else { return }
        button.performClick(nil)
    }

    private static func statusBarButton() -> NSStatusBarButton? {
        for window in NSApp.windows where window.className.contains("StatusBarWindow") {
            if let button = findView(NSStatusBarButton.self, in: window.contentView) {
                return button
            }
        }
        return nil
    }

    private static func findView<T: NSView>(_ type: T.Type, in view: NSView?) -> T? {
        guard let view else { return nil }
        if let match = view as? T { return match }
        for subview in view.subviews {
            if let match = findView(type, in: subview) { return match }
        }
        return nil
    }
}
