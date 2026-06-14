//
//  GetKeywordSuggestionsResponseDTO.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

import Foundation

struct GetKeywordSuggestionsResponseDTO: Decodable {
    let status: Int?
    let body: GetKeywordSuggestionsBodyDTO?
}

struct GetKeywordSuggestionsBodyDTO: Decodable {
    let data: [KeywordSuggestionsDTO]?
}

struct KeywordSuggestionsDTO: Decodable {
    let keyword: String?
    let link: String?
    let source: String?
    
    func toEntity() -> KeywordSuggestions {
        return KeywordSuggestions(keyword: keyword ?? "")
    }
}
