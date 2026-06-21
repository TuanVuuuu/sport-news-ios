//
//  SavedNewsItem.swift
//  sportnews
//

import Foundation

struct SavedNewsItem: Codable, Identifiable, Hashable {
    let id: String
    let categoryId: String
    let categoryName: String
    let savedAt: Date
}
