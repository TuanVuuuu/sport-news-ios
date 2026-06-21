//
//  UnregisterDeviceUseCase.swift
//  sportnews
//

import Foundation

protocol UnregisterDeviceUseCaseProtocol {
    func execute(deviceId: String) async throws
}

final class UnregisterDeviceUseCase: UnregisterDeviceUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    func execute(deviceId: String) async throws {
        try await repository.unregisterDevice(deviceId: deviceId)
    }
}
