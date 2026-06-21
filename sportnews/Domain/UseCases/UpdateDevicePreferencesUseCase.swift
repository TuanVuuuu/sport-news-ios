//
//  UpdateDevicePreferencesUseCase.swift
//  sportnews
//

import Foundation

protocol UpdateDevicePreferencesUseCaseProtocol {
    func execute(
        deviceId: String,
        enabled: Bool?,
        maxPerDay: Int?,
        categories: [String]?
    ) async throws -> DevicePreferencesRecord
}

final class UpdateDevicePreferencesUseCase: UpdateDevicePreferencesUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    func execute(
        deviceId: String,
        enabled: Bool? = nil,
        maxPerDay: Int? = nil,
        categories: [String]? = nil
    ) async throws -> DevicePreferencesRecord {
        try await repository.updatePreferences(
            deviceId: deviceId,
            enabled: enabled,
            maxPerDay: maxPerDay,
            categories: categories
        )
    }
}
