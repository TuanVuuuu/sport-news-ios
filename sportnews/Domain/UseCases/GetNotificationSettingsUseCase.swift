//
//  GetNotificationSettingsUseCase.swift
//  sportnews
//

import Foundation

protocol GetNotificationSettingsUseCaseProtocol {
    func execute() async throws -> NotificationSettings
}

final class GetNotificationSettingsUseCase: GetNotificationSettingsUseCaseProtocol {
    private let repository: NotificationRepositoryProtocol

    init(repository: NotificationRepositoryProtocol = NotificationRepository()) {
        self.repository = repository
    }

    func execute() async throws -> NotificationSettings {
        try await repository.getSettings()
    }
}
