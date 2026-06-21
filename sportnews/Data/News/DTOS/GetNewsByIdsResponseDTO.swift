//
//  GetNewsByIdsResponseDTO.swift
//  sportnews
//

import Foundation

struct GetNewsByIdsResponseDTO: Decodable {
    let status: Int
    let body: NewsByIdsBodyDTO?
}

struct NewsByIdsBodyDTO: Decodable {
    let data: [NewsArticleDTO]?
    let not_found: [String]?
}
