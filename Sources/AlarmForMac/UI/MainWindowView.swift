import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MainWindowView: View {
    @ObservedObject private var store = AppServices.shared.store
    @ObservedObject private var settingsStore = AppServices.shared.settingsStore

    @State private var importMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if store.alarms.isEmpty {
                VStack(spacing: 10) {
                    Text("💤")
                        .font(.system(size: 52))
                    Text("Henüz alarm yok")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text("Aşağıdaki formdan ekle ya da JSON dosyasından içe aktar.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(store.alarms) { alarm in
                            AlarmRow(alarm: alarm)
                        }
                    }
                    .padding(14)
                }
            }

            Divider()

            AddAlarmForm(compact: false)
                .padding(12)
        }
        .frame(minWidth: 440, minHeight: 380)
        .toolbar {
            ToolbarItem {
                Button {
                    importJSON()
                } label: {
                    Label("JSON İçe Aktar", systemImage: "square.and.arrow.down")
                }
                .help("JSON dosyasından alarm içe aktar")
            }
        }
        .alert("İçe Aktarma", isPresented: Binding(
            get: { importMessage != nil },
            set: { if !$0 { importMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(importMessage ?? "")
        }
    }

    private func importJSON() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.message = "Alarm listesi içeren bir JSON dosyası seç"
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let result = store.importJSON(from: url)
        if result.added == 0 && result.skipped == 0 {
            importMessage = "Dosya okunamadı ya da geçerli alarm bulunamadı. Beklenen biçim: [{\"time\":\"23:00\",\"name\":\"uyku\"}]"
        } else {
            var message = "\(result.added) alarm içe aktarıldı. 🎉"
            if result.skipped > 0 {
                message += "\n\(result.skipped) kayıt geçersiz saat nedeniyle atlandı."
            }
            importMessage = message
        }
    }
}
