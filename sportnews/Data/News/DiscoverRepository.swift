//
//  DiscoverRepository.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation

struct DiscoverRepository: DiscoverRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDiscoverData() async throws -> [DiscoverSection] {
        let endpoint = NewsEndpoint.getDiscover
        
        let apiResponse: GetDiscoverResponseDTO = try await self.networkService.request(endpoint)
        
        let dtoList = apiResponse.body?.data ?? []
        
        return dtoList.map { $0.toEntity() }
    }
    
    func fetchKeywordSuggestions() async throws -> [KeywordSuggestions] {
        let endpoint = NewsEndpoint.getSuggestions(limit: 10)
        
        let apiResponse: GetKeywordSuggestionsResponseDTO = try await
        self.networkService.request(endpoint)
        
        let dtoList = apiResponse.body?.data ?? []
        
        return dtoList.map { $0.toEntity() }
    }
    
    func fetchNewsSearchData(text: String) async throws -> [DiscoverSection] {
        let endpoint = NewsEndpoint.getNewsSearch(page: 0, size: 20, text: text)
        let apiResponse: GetNewsListResponseDTO = try await networkService.request(endpoint)
        
        let dtoList = apiResponse.body?.data ?? []
        
        // Bước 1: Map DTO → SportNews
        let articles = dtoList.map { $0.toDomain() }
        
        // Bước 2: Gom nhóm theo category_name
        let grouped = Dictionary(grouping: articles) { article in
            article.category.isEmpty ? "Khác" : article.category
        }
        
        // Bước 3: Chuyển thành [DiscoverSection]
        return grouped.map { categoryName, items in
            DiscoverSection(
                id: categoryName,
                title: categoryName,
                articles: items
            )
        }
        .sorted { $0.title < $1.title }  // tuỳ chọn: sắp xếp section
    }
}
