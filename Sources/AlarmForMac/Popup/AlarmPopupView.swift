import SwiftUI

struct AlarmPopupView: View {
    let alarm: Alarm
    let theme: PopupTheme
    let style: PopupAnimationStyle
    let onClose: () -> Void

    @State private var pulsing = false
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            Text(alarm.emoji)
                .font(.system(size: 40))
                .frame(width: 64, height: 64)
                .background(Circle().fill(.white.opacity(0.3)))
                .scaleEffect(pulsing ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulsing)

            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(alarm.time)  ·  Alarm time!")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 340, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
        .padding(20) // so the shadow stays inside the window
        // Entrance animation on the content instead of the window: the window is
        // placed fixed at its final position while the content slides / bounces / fades in from the right.
        .offset(x: appeared ? 0 : entranceOffsetX)
        .opacity(appeared || style != .fade ? 1 : 0)
        .onAppear {
            pulsing = true
            withAnimation(entranceAnimation) { appeared = true }
        }
    }

    private var entranceOffsetX: CGFloat {
        style == .fade ? 0 : 420
    }

    private var entranceAnimation: Animation {
        switch style {
        case .slide: return .easeOut(duration: 0.4)
        case .bounce: return .spring(response: 0.5, dampingFraction: 0.55)
        case .fade: return .easeIn(duration: 0.45)
        }
    }
}
