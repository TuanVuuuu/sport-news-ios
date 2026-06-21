//
//  NotificationEndpoint.swift
//  sportnews
//

import Foundation

enum NotificationEndpoint: APIEndpoint {
    case getSettings
    case registerDevice(deviceId: String, fcmToken: String, preferences: DevicePreferences?)
    case getPreferences(deviceId: String)
    case updatePreferences(deviceId: String, enabled: Bool?, maxPerDay: Int?, categories: [String]?)
    case unregisterDevice(deviceId: String)

    var path: String {
        switch self {
        case .getSettings:
            return "api/notifications/settings"
        case .registerDevice:
            return "api/devices/register"
        case .getPreferences(let deviceId):
            return "api/devices/\(deviceId)/preferences"
        case .updatePreferences(let deviceId, _, _, _):
            return "api/devices/\(deviceId)/preferences"
        case .unregisterDevice(let deviceId):
            return "api/devices/\(deviceId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getSettings, .getPreferences:
            return .get
        case .registerDevice:
            return .post
        case .updatePreferences:
            return .put
        case .unregisterDevice:
            return .delete
        }
    }

    var queryParameters: [String: Any]? {
        nil
    }

    var bodyParameters: [String: Any]? {
        switch self {
        case .getSettings, .getPreferences, .unregisterDevice:
            return nil

        case .registerDevice(let deviceId, let fcmToken, let preferences):
            var body: [String: Any] = [
                "device_id": deviceId,
                "fcm_token": fcmToken,
                "platform": "ios"
            ]

            if let preferences {
                body["preferences"] = preferencesBody(from: preferences)
            }

            return body

        case .updatePreferences(_, let enabled, let maxPerDay, let categories):
            var body: [String: Any] = [:]

            if let enabled {
                body["enabled"] = enabled
            }

            if let maxPerDay {
                body["max_per_day"] = maxPerDay
            }

            if let categories {
                body["categories"] = categories
            }

            return body.isEmpty ? nil : body
        }
    }

    private func preferencesBody(from preferences: DevicePreferences) -> [String: Any] {
        [
            "enabled": preferences.enabled,
            "max_per_day": preferences.maxPerDay,
            "categories": preferences.categories
        ]
    }
}
