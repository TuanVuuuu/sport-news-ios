//
//  NotificationResponseDTO.swift
//  sportnews
//

import Foundation

struct NotificationApiResponseDTO<T: Decodable>: Decodable {
    let status: Int
    let body: NotificationApiBodyDTO<T>?
}

struct NotificationApiBodyDTO<T: Decodable>: Decodable {
    let data: T?
    let message: String?
}

struct NotificationSettingsDataDTO: Decodable {
    let enabled: Bool
    let defaults: NotificationDefaultsDTO
    let limits: NotificationLimitsDTO
    let time_slots: [NotificationTimeSlotDTO]
    let timezone: String
    let topic: String

    func toDomain() -> NotificationSettings {
        NotificationSettings(
            enabled: enabled,
            defaultEnabled: defaults.enabled,
            defaultMaxPerDay: defaults.maxPerDay,
            defaultCategories: defaults.categories,
            maxPerDayLimit: limits.max_per_day,
            maxArticlesPerNotification: limits.max_articles_per_notification,
            timeSlots: time_slots.map { $0.toDomain() },
            timezone: timezone,
            topic: topic
        )
    }
}

struct NotificationDefaultsDTO: Decodable {
    let enabled: Bool
    let maxPerDay: Int
    let categories: [String]
}

struct NotificationLimitsDTO: Decodable {
    let max_per_day: Int
    let max_articles_per_notification: Int
}

struct NotificationTimeSlotDTO: Decodable {
    let id: String
    let label: String
    let start_hour: Int
    let end_hour: Int

    func toDomain() -> NotificationTimeSlot {
        NotificationTimeSlot(
            id: id,
            label: label,
            startHour: start_hour,
            endHour: end_hour
        )
    }
}

struct DevicePreferencesDTO: Decodable {
    let enabled: Bool
    let max_per_day: Int
    let categories: [String]

    func toDomain() -> DevicePreferences {
        DevicePreferences(
            enabled: enabled,
            maxPerDay: max_per_day,
            categories: categories
        )
    }
}

struct DevicePreferencesDataDTO: Decodable {
    let device_id: String
    let preferences: DevicePreferencesDTO
    let updated_at: String?

    func toDomain() -> DevicePreferencesRecord {
        DevicePreferencesRecord(
            deviceId: device_id,
            preferences: preferences.toDomain(),
            updatedAt: updated_at
        )
    }
}

struct RegisteredDeviceDataDTO: Decodable {
    let device_id: String
    let platform: String?
    let preferences: DevicePreferencesDTO
    let created_at: String?
    let updated_at: String?

    func toDomain() -> RegisteredDevice {
        RegisteredDevice(
            deviceId: device_id,
            platform: platform,
            preferences: preferences.toDomain(),
            createdAt: created_at,
            updatedAt: updated_at
        )
    }
}

struct UnregisterDeviceDataDTO: Decodable {
    let device_id: String
    let removed: Bool
}
