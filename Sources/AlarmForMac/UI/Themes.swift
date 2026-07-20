import SwiftUI

extension PopupTheme {
    var displayName: String {
        switch self {
        case .peach: return "Peach 🍑"
        case .lavender: return "Lavender 💜"
        case .mint: return "Mint 🌿"
        case .sky: return "Sky ☁️"
        case .sunset: return "Sunset 🌅"
        }
    }

    var colors: [Color] {
        switch self {
        case .peach: return [Color(hex: 0xFF9A8B), Color(hex: 0xFF6A88)]
        case .lavender: return [Color(hex: 0xA18CD1), Color(hex: 0xFBC2EB)]
        case .mint: return [Color(hex: 0x43E97B), Color(hex: 0x38F9D7)]
        case .sky: return [Color(hex: 0x89F7FE), Color(hex: 0x66A6FF)]
        case .sunset: return [Color(hex: 0xFA709A), Color(hex: 0xFEE140)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Shared picker that shows theme colors as circular swatches.
struct ThemeSwatchPicker: View {
    @Binding var selection: PopupTheme
    var size: CGFloat = 20
    /// Index of the color focused during keyboard navigation (shown with a ring).
    var focusedIndex: Int? = nil

    var body: some View {
        HStack(spacing: 7) {
            ForEach(Array(PopupTheme.allCases.enumerated()), id: \.element) { index, theme in
                Circle()
                    .fill(theme.gradient)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle().strokeBorder(
                            selection == theme ? Color.primary : .clear,
                            lineWidth: 2
                        )
                    )
                    .overlay {
                        if focusedIndex == index {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .padding(-3)
                        }
                    }
                    .onTapGesture { selection = theme }
                    .help(theme.displayName)
            }
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
