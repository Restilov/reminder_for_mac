import AppKit
import SwiftUI

/// Shared reminder-adding form for the menu panel and the main window.
/// Tab / Shift+Tab moves through the whole form: hour → minute → name → emoji →
/// add button → colors → (wraps around). When the button or colors are focused,
/// Enter/Space activates them; typing 2 digits auto-advances to the next field.
struct AddReminderForm: View {
    var compact: Bool

    @ObservedObject private var store = AppServices.shared.store
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    private enum Stop: Hashable {
        case hour, minute, name, emoji, add, color(Int)

        var isTextField: Bool {
            switch self {
            case .hour, .minute, .name, .emoji: return true
            default: return false
            }
        }
    }

    private static let stops: [Stop] =
        [.hour, .minute, .name, .emoji, .add] + PopupTheme.allCases.indices.map { .color($0) }

    @FocusState private var fieldFocus: Stop?
    @State private var focusStop: Stop?
    @State private var hostWindow: NSWindow?
    @State private var keyMonitor: Any?

    @State private var hourText = ""
    @State private var minuteText = ""
    @State private var name = ""
    @State private var emoji = ""
    @State private var theme: PopupTheme = .peach

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                TextField("23", text: $hourText)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(width: 34)
                    .focused($fieldFocus, equals: .hour)
                    .onSubmit(add)
                Text(":")
                    .foregroundStyle(.secondary)
                TextField("00", text: $minuteText)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(width: 34)
                    .focused($fieldFocus, equals: .minute)
                    .onSubmit(add)
                TextField(compact ? "name (e.g. sleep)" : "Reminder name (e.g. sleep)", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($fieldFocus, equals: .name)
                    .onSubmit(add)
                TextField("⏰", text: $emoji)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: compact ? 36 : 44)
                    .focused($fieldFocus, equals: .emoji)
                    .onSubmit(add)
                addButton
            }
            HStack(spacing: 8) {
                Text(compact ? "Color:" : "Popup color:")
                    .font(.system(size: compact ? 11 : 12, design: .rounded))
                    .foregroundStyle(.secondary)
                ThemeSwatchPicker(
                    selection: $theme,
                    size: compact ? 18 : 20,
                    focusedIndex: focusedColorIndex
                )
                Spacer()
            }
        }
        .background(WindowAccessor { hostWindow = $0 })
        .onAppear {
            resetFields()
            installKeyMonitor()
        }
        .onDisappear(perform: removeKeyMonitor)
        .onChange(of: fieldFocus) { _, new in
            // Sync the virtual focus when the user changes focus by clicking.
            if let new {
                focusStop = new
            } else if let current = focusStop, current.isTextField {
                focusStop = nil
            }
        }
        .onChange(of: hourText) { _, new in
            hourText = sanitized(new, max: 23)
            if hourText.count == 2 && fieldFocus == .hour { setFocus(.minute) }
        }
        .onChange(of: minuteText) { _, new in
            minuteText = sanitized(new, max: 59)
            if minuteText.count == 2 && fieldFocus == .minute { setFocus(.name) }
        }
    }

    @ViewBuilder
    private var addButton: some View {
        if compact {
            Button(action: add) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.pink)
            }
            .buttonStyle(.plain)
            .overlay {
                if focusStop == .add {
                    Circle().stroke(Color.accentColor, lineWidth: 2).padding(-3)
                }
            }
            .help("Add reminder")
        } else {
            Button(action: add) {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut(.defaultAction)
            .overlay {
                if focusStop == .add {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.accentColor, lineWidth: 2)
                        .padding(-3)
                }
            }
        }
    }

    private var focusedColorIndex: Int? {
        if case .color(let index) = focusStop { return index }
        return nil
    }

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.window === hostWindow else { return event }
            switch event.keyCode {
            case 48: // Tab
                advanceFocus(backwards: event.modifierFlags.contains(.shift))
                return nil
            case 36, 76, 49: // Return, Enter, Space
                guard let stop = focusStop, !stop.isTextField else { return event }
                switch stop {
                case .add:
                    add()
                case .color(let index):
                    theme = PopupTheme.allCases[index]
                default:
                    break
                }
                return nil
            case 53 where compact: // Esc closes the menu panel
                hostWindow?.close()
                return nil
            default:
                return event
            }
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        keyMonitor = nil
        focusStop = nil
    }

    private func advanceFocus(backwards: Bool) {
        let stops = Self.stops
        let next: Stop
        if let current = focusStop ?? fieldFocus, let index = stops.firstIndex(of: current) {
            let offset = backwards ? stops.count - 1 : 1
            next = stops[(index + offset) % stops.count]
        } else {
            next = backwards ? stops[stops.count - 1] : .hour
        }
        setFocus(next)
    }

    private func setFocus(_ stop: Stop) {
        focusStop = stop
        fieldFocus = stop.isTextField ? stop : nil
    }

    private func sanitized(_ text: String, max: Int) -> String {
        let digits = String(text.filter(\.isNumber).prefix(2))
        if let value = Int(digits), value > max { return String(max) }
        return digits
    }

    private func add() {
        guard let hour = Int(hourText), let minute = Int(minuteText) else {
            setFocus(hourText.isEmpty ? .hour : .minute)
            return
        }
        let time = String(format: "%02d:%02d", hour, minute)
        store.add(time: time, name: name, emoji: emoji, theme: theme)
        name = ""
        emoji = ""
        // The color picker resets to the default after every add.
        theme = settingsStore.settings.theme
        setFocus(.hour)
    }

    private func resetFields() {
        theme = settingsStore.settings.theme
        let now = Date()
        hourText = String(format: "%02d", Calendar.current.component(.hour, from: now))
        minuteText = String(format: "%02d", Calendar.current.component(.minute, from: now))
    }
}

/// Provides access to the NSWindow that hosts the SwiftUI view.
private struct WindowAccessor: NSViewRepresentable {
    var onWindow: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { onWindow(view.window) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { onWindow(nsView.window) }
    }
}
