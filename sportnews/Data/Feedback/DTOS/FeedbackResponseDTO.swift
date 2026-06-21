//
//  FeedbackResponseDTO.swift
//  sportnews
//

import Foundation

struct FeedbackDataDTO: Decodable {
    let id: String
    let message: String

    func toDomain() -> FeedbackResult {
        FeedbackResult(id: id, message: message)
    }
}
