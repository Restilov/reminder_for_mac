import AppKit
import SwiftUI

/// Allows the borderless panel to receive keyboard/click focus.
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

struct QuitConfirmView: View {
    let theme: PopupTheme
    let onQuit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🥺")
                .font(.system(size: 44))
            Text("If you quit the app,\nyour reminders won't go off!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white))
                        .foregroundStyle(.black.opacity(0.7))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)

                Button(action: onQuit) {
                    Text("Quit Anyway")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.25)))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(28)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.gradient)
        )
        .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
        .padding(24)
    }
}

enum QuitConfirm {
    private static var panel: NSPanel?

    static func requestQuit(settingsStore: SettingsStore) {
        guard settingsStore.settings.confirmQuit else {
            NSApp.terminate(nil)
            return
        }
        if let existing = panel {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let confirmPanel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 330, height: 240),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        confirmPanel.isOpaque = false
        confirmPanel.backgroundColor = .clear
        confirmPanel.hasShadow = false
        confirmPanel.level = .modalPanel
        confirmPanel.collectionBehavior = [.canJoinAllSpaces]
        confirmPanel.isReleasedWhenClosed = false

        let view = QuitConfirmView(
            theme: settingsStore.settings.theme,
            onQuit: { NSApp.terminate(nil) },
            onCancel: {
                panel?.orderOut(nil)
                panel = nil
            }
        )
        confirmPanel.contentView = NSHostingView(rootView: view)
        confirmPanel.center()
        confirmPanel.makeKeyAndOrderFront(nil)
        panel = confirmPanel
    }
}
