//
//  SavedNewsStorage.swift
//  sportnews
//

import Foundation

enum SavedNewsStorage {
    private static let storageKey = "saved_news.items"

    static func loadAll() -> [SavedNewsItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([SavedNewsItem].self, from: data) else {
            return []
        }
        return items
    }

    static func save(_ item: SavedNewsItem) {
        var items = loadAll().filter { $0.id != item.id }
        items.insert(item, at: 0)
        persist(items)
    }

    static func remove(id: String) {
        let items = loadAll().filter { $0.id != id }
        persist(items)
    }

    static func isSaved(id: String) -> Bool {
        loadAll().contains { $0.id == id }
    }

    static func savedIds() -> Set<String> {
        Set(loadAll().map(\.id))
    }

    static func items(for categoryId: String) -> [SavedNewsItem] {
        loadAll()
            .filter { $0.categoryId == categoryId }
            .sorted { $0.savedAt > $1.savedAt }
    }

    static func categories() -> [SportCategory] {
        let grouped = Dictionary(grouping: loadAll(), by: \.categoryId)
        return grouped
            .map { categoryId, items in
                let latestSave = items.map(\.savedAt).max() ?? .distantPast
                let name = items.first?.categoryName ?? categoryId
                return (SportCategory(id: categoryId, name: name), latestSave)
            }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }

    @discardableResult
    static func toggle(id: String, categoryId: String, categoryName: String) -> Bool {
        if isSaved(id: id) {
            remove(id: id)
            return false
        }
        save(
            SavedNewsItem(
                id: id,
                categoryId: categoryId,
                categoryName: categoryName,
                savedAt: Date()
            )
        )
        return true
    }

    private static func persist(_ items: [SavedNewsItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
