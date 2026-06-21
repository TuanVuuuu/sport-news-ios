//
//  SavedNewsRepository.swift
//  sportnews
//

import Foundation

final class SavedNewsRepository: SavedNewsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func getNewsByIds(ids: [String], category: String) async throws -> NewsByIdsResult {
        let endpoint = NewsEndpoint.getNewsByIds(ids: ids, category: category)
        let response: GetNewsByIdsResponseDTO = try await networkService.request(endpoint)
        let articles = response.body?.data?.map { $0.toDomain() } ?? []
        let notFound = response.body?.not_found ?? []
        return NewsByIdsResult(articles: articles, notFound: notFound)
    }
}
