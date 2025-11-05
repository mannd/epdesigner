import SwiftUI

struct AppSettings {
    static let shared = AppSettings()
    private init() {}
}

struct SettingsKeys {
    static let sidebarColoredText = "sidebarColoredText"
    static let defaultRootLabel = "defaultRootLabel"
    static let confirmDestructiveActions = "confirmDestructiveActions"
}

final class SettingsStore: ObservableObject {
    init() {
        let defaults = UserDefaults.standard
        self.sidebarColoredText = defaults.object(forKey: SettingsKeys.sidebarColoredText) as? Bool ?? true
        self.defaultRootLabel = defaults.string(forKey: SettingsKeys.defaultRootLabel) ?? "Root"
        self.confirmDestructiveActions = defaults.object(forKey: SettingsKeys.confirmDestructiveActions) as? Bool ?? true
    }

    @Published var sidebarColoredText: Bool {
        didSet { UserDefaults.standard.set(sidebarColoredText, forKey: SettingsKeys.sidebarColoredText) }
    }

    @Published var defaultRootLabel: String {
        didSet { UserDefaults.standard.set(defaultRootLabel, forKey: SettingsKeys.defaultRootLabel) }
    }

    @Published var confirmDestructiveActions: Bool {
        didSet { UserDefaults.standard.set(confirmDestructiveActions, forKey: SettingsKeys.confirmDestructiveActions) }
    }
}

private struct SettingsStoreKey: EnvironmentKey {
    static let defaultValue = SettingsStore() // or whatever your default is
}

extension EnvironmentValues {
    var settingsStore: SettingsStore {
        get { self[SettingsStoreKey.self] }
        set { self[SettingsStoreKey.self] = newValue }
    }
}
