//
//  NotificationSettingsStorage.swift
//  sportnews
//

import Foundation

enum NotificationSettingsStorage {
    static let enabledKey = "notification_settings.breakingNews"
    static let frequencyKey = "notification_settings.frequency"

    static func ensureDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: enabledKey) == nil else { return }
        save(enabled: true, frequency: .threePerDay)
    }

    static func save(enabled: Bool, frequency: NotificationFrequency) {
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: enabledKey)
        defaults.set(frequency.rawValue, forKey: frequencyKey)
    }

    static func loadEnabled(default defaultValue: Bool = true) -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: enabledKey) != nil {
            return defaults.bool(forKey: enabledKey)
        }
        return defaultValue
    }

    static func loadFrequency(default defaultValue: NotificationFrequency = .threePerDay) -> NotificationFrequency {
        let raw = UserDefaults.standard.integer(forKey: frequencyKey)
        return NotificationFrequency(rawValue: raw) ?? defaultValue
    }

    static func currentPreferences() -> DevicePreferences {
        .featured(enabled: loadEnabled(), frequency: loadFrequency())
    }
}
