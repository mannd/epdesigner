import SwiftUI
import Observation

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        #if os(macOS)
        Form {
            Section("General") {
                TextField("Default root label", text: $settings.defaultRootLabel)
                Toggle("Confirm before destructive actions", isOn: $settings.confirmDestructiveActions)
            }
            Section("Appearance") {
                Toggle("Colorize sidebar text", isOn: $settings.sidebarColoredText)
            }
        }
        .frame(minWidth: 420)
        #else
        NavigationStack {
            Form {
                Section("General") {
                    TextField("Default root label", text: $settings.defaultRootLabel)
                    Toggle("Confirm before destructive actions", isOn: $settings.confirmDestructiveActions)
                }
                Section("Appearance") {
                    Toggle("Colorize sidebar text", isOn: $settings.sidebarColoredText)
                }
            }
            .navigationTitle("Settings")
        }
        #endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore())
}
