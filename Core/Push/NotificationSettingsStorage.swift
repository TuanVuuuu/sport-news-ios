//
//  NotificationSettingsStorage.swift
//  sportnews
//

import Foundation

enum NotificationSettingsStorage {
    static let enabledKey = "notification_settings.breakingNews"
    static let frequencyKey = "notification_settings.frequency"

    private static var cloudStore: NSUbiquitousKeyValueStore { .default }

    static func ensureDefaultsIfNeeded() {
        syncFromCloudIfNeeded()

        let defaults = UserDefaults.standard
        guard defaults.object(forKey: enabledKey) == nil else { return }
        save(enabled: true, frequency: .threePerDay)
    }

    static func syncFromCloudIfNeeded() {
        cloudStore.synchronize()

        let defaults = UserDefaults.standard
        guard defaults.object(forKey: enabledKey) == nil else { return }
        applyCloudValuesToLocal()
    }

    static func save(enabled: Bool, frequency: NotificationFrequency) {
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: enabledKey)
        defaults.set(frequency.rawValue, forKey: frequencyKey)

        cloudStore.set(enabled, forKey: enabledKey)
        cloudStore.set(Int64(frequency.rawValue), forKey: frequencyKey)
        cloudStore.synchronize()
    }

    static func loadEnabled(default defaultValue: Bool = true) -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: enabledKey) != nil {
            return defaults.bool(forKey: enabledKey)
        }

        if let cloudValue = readEnabledFromCloud() {
            defaults.set(cloudValue, forKey: enabledKey)
            return cloudValue
        }

        return defaultValue
    }

    static func loadFrequency(default defaultValue: NotificationFrequency = .threePerDay) -> NotificationFrequency {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: frequencyKey) != nil {
            let raw = defaults.integer(forKey: frequencyKey)
            return NotificationFrequency(rawValue: raw) ?? defaultValue
        }

        if let cloudFrequency = readFrequencyFromCloud() {
            defaults.set(cloudFrequency.rawValue, forKey: frequencyKey)
            return cloudFrequency
        }

        return defaultValue
    }

    static func currentPreferences() -> DevicePreferences {
        .featured(enabled: loadEnabled(), frequency: loadFrequency())
    }

    private static func applyCloudValuesToLocal() {
        guard readEnabledFromCloud() != nil else { return }

        let defaults = UserDefaults.standard
        defaults.set(cloudStore.bool(forKey: enabledKey), forKey: enabledKey)

        if let frequency = readFrequencyFromCloud() {
            defaults.set(frequency.rawValue, forKey: frequencyKey)
        }
    }

    private static func readEnabledFromCloud() -> Bool? {
        cloudStore.synchronize()
        guard cloudStore.object(forKey: enabledKey) != nil else { return nil }
        return cloudStore.bool(forKey: enabledKey)
    }

    private static func readFrequencyFromCloud() -> NotificationFrequency? {
        cloudStore.synchronize()
        guard cloudStore.object(forKey: frequencyKey) != nil else { return nil }
        let raw = Int(cloudStore.longLong(forKey: frequencyKey))
        return NotificationFrequency(rawValue: raw)
    }
}
