//
//  DevicePreferences+NotificationFrequency.swift
//  sportnews
//

import Foundation

extension DevicePreferences {
    static func featured(enabled: Bool, frequency: NotificationFrequency) -> DevicePreferences {
        DevicePreferences(
            enabled: enabled,
            maxPerDay: frequency.rawValue,
            categories: ["featured"]
        )
    }

    var frequency: NotificationFrequency {
        NotificationFrequency(rawValue: maxPerDay) ?? .threePerDay
    }
}
