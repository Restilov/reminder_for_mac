import AppKit
import SwiftUI

/// Shows animated reminder popups in the bottom-right corner; stacks them if multiple
/// reminders fire at once. The window is placed directly at its final position, and the
/// entrance animation plays in the SwiftUI content (window animation is unreliable).
final class PopupPresenter {
    private let settingsStore: SettingsStore
    private var panels: [NSPanel] = []

    private static let panelSize = NSSize(width: 380, height: 140) // content + shadow margin
    private static let margin: CGFloat = 8

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }

    func show(reminder: Reminder) {
        let settings = settingsStore.settings

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: Self.panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false

        let view = ReminderPopupView(reminder: reminder, theme: reminder.theme ?? settings.theme, style: settings.animation) { [weak self, weak panel] in
            guard let self, let panel else { return }
            self.dismiss(panel)
        }
        panel.contentView = NSHostingView(rootView: view)

        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return
        }
        let visible = screen.visibleFrame
        let stackOffset = CGFloat(panels.count) * (Self.panelSize.height - 20)
        let origin = NSPoint(
            x: visible.maxX - Self.panelSize.width - Self.margin,
            y: visible.minY + Self.margin + stackOffset
        )

        panel.setFrameOrigin(origin)
        panel.orderFrontRegardless()
        panels.append(panel)

        if settings.soundEnabled {
            NSSound(named: NSSound.Name(settings.soundName))?.play()
        }

        if settings.popupDuration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.popupDuration) { [weak self, weak panel] in
                guard let self, let panel, self.panels.contains(panel) else { return }
                self.dismiss(panel)
            }
        }
    }

    private func dismiss(_ panel: NSPanel) {
        panels.removeAll { $0 === panel }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }
}
