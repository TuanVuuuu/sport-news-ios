//
//  FeedbackRepository.swift
//  sportnews
//

import Foundation

final class FeedbackRepository: FeedbackRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func submit(_ submission: FeedbackSubmission) async throws -> FeedbackResult {
        let endpoint = FeedbackEndpoint.submit(submission)
        let response: NotificationApiResponseDTO<FeedbackDataDTO> = try await networkService.request(endpoint)
        let data = try unwrap(response)
        return data.toDomain()
    }

    private func unwrap<T>(_ response: NotificationApiResponseDTO<T>) throws -> T {
        guard response.status == 1, let data = response.body?.data else {
            throw FeedbackAPIError.serverMessage(
                response.body?.message ?? "Không nhận được dữ liệu từ server."
            )
        }
        return data
    }
}
