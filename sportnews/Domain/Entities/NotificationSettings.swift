//
//  NotificationSettings.swift
//  sportnews
//

import Foundation

struct NotificationSettings: Equatable {
    let enabled: Bool
    let defaultEnabled: Bool
    let defaultMaxPerDay: Int
    let defaultCategories: [String]
    let maxPerDayLimit: Int
    let maxArticlesPerNotification: Int
    let timeSlots: [NotificationTimeSlot]
    let timezone: String
    let topic: String
}

struct NotificationTimeSlot: Equatable, Identifiable {
    let id: String
    let label: String
    let startHour: Int
    let endHour: Int
}

struct DevicePreferences: Equatable {
    let enabled: Bool
    let maxPerDay: Int
    let categories: [String]
}

struct DevicePreferencesRecord: Equatable {
    let deviceId: String
    let preferences: DevicePreferences
    let updatedAt: String?
}

struct RegisteredDevice: Equatable {
    let deviceId: String
    let platform: String?
    let preferences: DevicePreferences
    let createdAt: String?
    let updatedAt: String?
}

enum NotificationAPIError: LocalizedError {
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .serverMessage(let message):
            return message
        }
    }
}
