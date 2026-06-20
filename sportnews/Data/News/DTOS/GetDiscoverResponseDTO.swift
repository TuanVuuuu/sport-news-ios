//
//  GetDiscoverResponseDTO.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation

struct GetDiscoverResponseDTO: Decodable {
    let status: Int?
    let body: DiscoverBodyDTO?
}

struct DiscoverBodyDTO: Decodable {
    let data: [DiscoverItemsDTO]?
}

struct DiscoverItemsDTO: Decodable {
    let id: String?
    let name: String?
    let latest_articles: [DiscoverItemDTO]?
    
    func toEntity() -> DiscoverSection {
        let mappedArticles = latest_articles?.map { $0.toEntity()} ?? []
        return DiscoverSection(
            id: id ?? UUID().uuidString,
            title: name ?? "Tin tức",
            articles: mappedArticles
        )
    }
}

struct DiscoverItemDTO: Decodable {
    let id: String?
    let title: String?
    let category_name: String?
    let source: String?
    let thumbnail_url: String?
    let thumbnail_blurhash: String?
    let subCategory: String?
    let published_at: String?
    
    func toEntity() -> SportNews {
        return SportNews(
            id: id ?? UUID().uuidString,
            title: title ?? "",
            source: source ?? "",
            timeAgo: (published_at ?? "").toRelativeTimeString(),
            category: "", // Khám phá không hiển thị thời gian thì để trống
            imageUrl: thumbnail_url ?? "",
            thumbnailBlurHash: thumbnail_blurhash,
            isFeatured: subCategory == "Featured"
        )
    }
}
