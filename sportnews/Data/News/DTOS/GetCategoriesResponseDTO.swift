//
//  GetCategoriesResponseDTO.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import Foundation

struct GetCategoriesResponseDTO: Decodable {
    let status: Int?
    let body: CategoriesBodyDTO?
}

struct CategoriesBodyDTO: Decodable {
    let data: [CategoryItemDTO]?
}

struct CategoryItemDTO: Decodable {
    let id: String?
    let name: String?
    
    func toDomain() -> SportCategory {
        return SportCategory(
            id: self.id ?? "",
            name: self.name ?? "Danh mục"
        )
    }
}
