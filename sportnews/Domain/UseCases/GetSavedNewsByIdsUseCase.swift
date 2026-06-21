//
//  GetSavedNewsByIdsUseCase.swift
//  sportnews
//

import Foundation

protocol GetSavedNewsByIdsUseCaseProtocol {
    func execute(ids: [String], categoryId: String) async throws -> NewsByIdsResult
}

final class GetSavedNewsByIdsUseCase: GetSavedNewsByIdsUseCaseProtocol {
    private let repository: SavedNewsRepositoryProtocol

    init(repository: SavedNewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(ids: [String], categoryId: String) async throws -> NewsByIdsResult {
        guard !ids.isEmpty else {
            return NewsByIdsResult(articles: [], notFound: [])
        }
        return try await repository.getNewsByIds(ids: ids, category: categoryId)
    }
}
