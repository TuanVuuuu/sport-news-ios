//
//  NotificationRepositoryProtocol.swift
//  sportnews
//

import Foundation

protocol NotificationRepositoryProtocol {
    func getSettings() async throws -> NotificationSettings
    func registerDevice(
        deviceId: String,
        fcmToken: String,
        preferences: DevicePreferences?
    ) async throws -> RegisteredDevice
    func getPreferences(deviceId: String) async throws -> DevicePreferencesRecord
    func updatePreferences(
        deviceId: String,
        enabled: Bool?,
        maxPerDay: Int?,
        categories: [String]?
    ) async throws -> DevicePreferencesRecord
    func unregisterDevice(deviceId: String) async throws
}
