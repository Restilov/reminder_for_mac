import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MainWindowView: View {
    @ObservedObject private var store = AppServices.shared.store
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    @State private var importMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if store.reminders.isEmpty {
                VStack(spacing: 10) {
                    Text("💤")
                        .font(.system(size: 52))
                    Text("No reminders yet")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text("Add one using the form below, or import from a JSON file.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(store.reminders) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                    .padding(14)
                }
            }

            Divider()

            AddReminderForm(compact: false)
                .padding(12)
        }
        .frame(minWidth: 440, minHeight: 380)
        .toolbar {
            ToolbarItem {
                Button {
                    importJSON()
                } label: {
                    Label("Import JSON", systemImage: "square.and.arrow.down")
                }
                .help("Import reminders from a JSON file")
            }
        }
        .alert("Import", isPresented: Binding(
            get: { importMessage != nil },
            set: { if !$0 { importMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importMessage ?? "")
        }
    }

    private func importJSON() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.message = "Select a JSON file containing a reminder list"
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let result = store.importJSON(from: url)
        if result.added == 0 && result.skipped == 0 {
            importMessage = "Couldn't read the file or no valid reminders found. Expected format: [{\"time\":\"23:00\",\"name\":\"sleep\"}]"
        } else {
            var message = "\(result.added) reminders imported. 🎉"
            if result.skipped > 0 {
                message += "\n\(result.skipped) entries were skipped due to an invalid time."
            }
            importMessage = message
        }
    }
}
