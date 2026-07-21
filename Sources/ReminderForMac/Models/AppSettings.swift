import Foundation

enum PopupTheme: String, Codable, CaseIterable, Identifiable {
    case peach, lavender, mint, sky, sunset

    var id: String { rawValue }
}

enum PopupAnimationStyle: String, Codable, CaseIterable, Identifiable {
    case slide, bounce, fade

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .slide: return "Slide"
        case .bounce: return "Bounce"
        case .fade: return "Fade"
        }
    }
}

struct AppSettings: Codable {
    var theme: PopupTheme = .peach
    var animation: PopupAnimationStyle = .bounce
    /// How long the popup stays on screen (seconds). 0 = stays until closed.
    var popupDuration: Double = 15
    var soundEnabled: Bool = true
    var soundName: String = "Glass"
    var confirmQuit: Bool = true
    /// Hotkey to toggle the menu panel (Carbon key code + modifiers).
    var hotkeyEnabled: Bool = true
    var hotkeyKeyCode: UInt32 = 0 // 'A'
    var hotkeyModifiers: UInt32 = 2304 // ⌥⌘
    var hotkeyLabel: String = "⌥⌘A"

    static let availableSounds = ["Glass", "Ping", "Purr", "Submarine", "Funk", "Blow", "Hero"]

    private enum CodingKeys: String, CodingKey {
        case theme, animation, popupDuration, soundEnabled, soundName, confirmQuit
        case hotkeyEnabled, hotkeyKeyCode, hotkeyModifiers, hotkeyLabel
    }

    init() {}

    // If settings.json is hand-edited, missing fields fall back to defaults.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decodeIfPresent(PopupTheme.self, forKey: .theme) ?? .peach
        animation = try container.decodeIfPresent(PopupAnimationStyle.self, forKey: .animation) ?? .bounce
        popupDuration = try container.decodeIfPresent(Double.self, forKey: .popupDuration) ?? 15
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        soundName = try container.decodeIfPresent(String.self, forKey: .soundName) ?? "Glass"
        confirmQuit = try container.decodeIfPresent(Bool.self, forKey: .confirmQuit) ?? true
        hotkeyEnabled = try container.decodeIfPresent(Bool.self, forKey: .hotkeyEnabled) ?? true
        hotkeyKeyCode = try container.decodeIfPresent(UInt32.self, forKey: .hotkeyKeyCode) ?? 0
        hotkeyModifiers = try container.decodeIfPresent(UInt32.self, forKey: .hotkeyModifiers) ?? 2304
        hotkeyLabel = try container.decodeIfPresent(String.self, forKey: .hotkeyLabel) ?? "⌥⌘A"
    }
}
