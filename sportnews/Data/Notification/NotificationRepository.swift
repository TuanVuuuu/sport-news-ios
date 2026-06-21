//
//  NotificationRepository.swift
//  sportnews
//

import Foundation

final class NotificationRepository: NotificationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func getSettings() async throws -> NotificationSettings {
        let endpoint = NotificationEndpoint.getSettings
        let response: NotificationApiResponseDTO<NotificationSettingsDataDTO> = try await networkService.request(endpoint)
        let data = try unwrap(response)
        return data.toDomain()
    }

    func registerDevice(
        deviceId: String,
        fcmToken: String,
        preferences: DevicePreferences?
    ) async throws -> RegisteredDevice {
        let endpoint = NotificationEndpoint.registerDevice(
            deviceId: deviceId,
            fcmToken: fcmToken,
            preferences: preferences
        )
        let response: NotificationApiResponseDTO<RegisteredDeviceDataDTO> = try await networkService.request(endpoint)
        let data = try unwrap(response)
        return data.toDomain()
    }

    func getPreferences(deviceId: String) async throws -> DevicePreferencesRecord {
        let endpoint = NotificationEndpoint.getPreferences(deviceId: deviceId)
        let response: NotificationApiResponseDTO<DevicePreferencesDataDTO> = try await networkService.request(endpoint)
        let data = try unwrap(response)
        return data.toDomain()
    }

    func updatePreferences(
        deviceId: String,
        enabled: Bool?,
        maxPerDay: Int?,
        categories: [String]?
    ) async throws -> DevicePreferencesRecord {
        let endpoint = NotificationEndpoint.updatePreferences(
            deviceId: deviceId,
            enabled: enabled,
            maxPerDay: maxPerDay,
            categories: categories
        )
        let response: NotificationApiResponseDTO<DevicePreferencesDataDTO> = try await networkService.request(endpoint)
        let data = try unwrap(response)
        return data.toDomain()
    }

    func unregisterDevice(deviceId: String) async throws {
        let endpoint = NotificationEndpoint.unregisterDevice(deviceId: deviceId)
        let response: NotificationApiResponseDTO<UnregisterDeviceDataDTO> = try await networkService.request(endpoint)
        _ = try unwrap(response)
    }

    private func unwrap<T>(_ response: NotificationApiResponseDTO<T>) throws -> T {
        guard response.status == 1, let data = response.body?.data else {
            throw NotificationAPIError.serverMessage(response.body?.message ?? "Không nhận được dữ liệu từ server.")
        }
        return data
    }
}
