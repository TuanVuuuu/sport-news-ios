//
//  SubmitFeedbackUseCase.swift
//  sportnews
//

import Foundation

protocol SubmitFeedbackUseCaseProtocol {
    func execute(_ submission: FeedbackSubmission) async throws -> FeedbackResult
}

final class SubmitFeedbackUseCase: SubmitFeedbackUseCaseProtocol {
    private let repository: FeedbackRepositoryProtocol

    init(repository: FeedbackRepositoryProtocol = FeedbackRepository()) {
        self.repository = repository
    }

    func execute(_ submission: FeedbackSubmission) async throws -> FeedbackResult {
        try await repository.submit(submission)
    }
}
