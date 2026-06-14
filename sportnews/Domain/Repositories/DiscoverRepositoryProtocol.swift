//
//  DiscoverRepository.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation

protocol DiscoverRepositoryProtocol {
    func fetchDiscoverData() async throws -> [DiscoverSection]
    
    func fetchKeywordSuggestions() async throws -> [KeywordSuggestions]
    
    func fetchNewsSearchData(text: String) async throws -> [DiscoverSection]
}
