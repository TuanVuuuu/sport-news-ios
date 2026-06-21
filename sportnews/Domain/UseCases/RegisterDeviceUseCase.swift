//
//  RegisterDeviceUseCase.swift
//  sportnews
//

import Foundation

protocol RegisterDeviceUseCaseProtocol {
    func execute(
        deviceId: String,
        fcmToken: String,
        preferences: DevicePreferences?
    ) async throws -> RegisteredDevice
}

final class RegisterDeviceUseCase: RegisterDeviceUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    func execute(
        deviceId: String,
        fcmToken: String,
        preferences: DevicePreferences? = nil
    ) async throws -> RegisteredDevice {
        try await repository.registerDevice(
            deviceId: deviceId,
            fcmToken: fcmToken,
            preferences: preferences
        )
    }
}
