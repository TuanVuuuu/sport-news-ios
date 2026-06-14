//
//  GetKeywordSuggestionsUseCase.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

protocol GetKeywordSuggestionsUseCaseProtocol {
    func excute() async throws -> [KeywordSuggestions]
    
    func search(text: String) async throws -> [DiscoverSection]
}

final class GetKeywordSuggestionsUseCase: GetKeywordSuggestionsUseCaseProtocol {
    private let repository: DiscoverRepositoryProtocol
    
    init(repository: DiscoverRepositoryProtocol) {
        self.repository = repository
    }
    
    func excute() async throws -> [KeywordSuggestions] {
        return try await repository.fetchKeywordSuggestions()
    }
    
    func search(text: String) async throws -> [DiscoverSection] {
        return try await repository.fetchNewsSearchData(text: text)
    }
}
