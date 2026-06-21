//
//  FeedbackRepositoryProtocol.swift
//  sportnews
//

import Foundation

protocol FeedbackRepositoryProtocol {
    func submit(_ submission: FeedbackSubmission) async throws -> FeedbackResult
}
