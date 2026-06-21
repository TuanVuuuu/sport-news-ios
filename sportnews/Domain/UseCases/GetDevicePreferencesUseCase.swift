//
//  GetDevicePreferencesUseCase.swift
//  sportnews
//

import Foundation

protocol GetDevicePreferencesUseCaseProtocol {
    func execute(deviceId: String) async throws -> DevicePreferencesRecord
}

final class GetDevicePreferencesUseCase: GetDevicePreferencesUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    func execute(deviceId: String) async throws -> DevicePreferencesRecord {
        try await repository.getPreferences(deviceId: deviceId)
    }
}
