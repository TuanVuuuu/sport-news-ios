//
//  NotificationSettingsViewModel.swift
//  sportnews
//

import Foundation
import Combine

@MainActor
final class NotificationSettingsViewModel: ObservableObject {
    @Published var isBreakingNewsEnabled: Bool
    @Published var selectedFrequency: NotificationFrequency

    private let settingsKey = "notification_settings"

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "\(settingsKey).breakingNews") != nil {
            isBreakingNewsEnabled = defaults.bool(forKey: "\(settingsKey).breakingNews")
        } else {
            isBreakingNewsEnabled = true
        }
        let raw = defaults.integer(forKey: "\(settingsKey).frequency")
        selectedFrequency = NotificationFrequency(rawValue: raw) ?? .threePerDay
    }

    func selectFrequency(_ frequency: NotificationFrequency) {
        selectedFrequency = frequency
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isBreakingNewsEnabled, forKey: "\(settingsKey).breakingNews")
        defaults.set(selectedFrequency.rawValue, forKey: "\(settingsKey).frequency")
    }
}
