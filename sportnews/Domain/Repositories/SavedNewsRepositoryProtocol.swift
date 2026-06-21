//
//  SavedNewsRepositoryProtocol.swift
//  sportnews
//

import Foundation

protocol SavedNewsRepositoryProtocol {
    func getNewsByIds(ids: [String], category: String) async throws -> NewsByIdsResult
}
