//
//  SavedNewsViewModel.swift
//  sportnews
//

import Foundation
import Combine

@MainActor
final class SavedNewsViewModel: ObservableObject {
    private static let batchSize = 20

    @Published var categories: [SportCategory] = []
    @Published var selectedCategory: SportCategory?
    @Published var articles: [SportNews] = []
    @Published var isLoading = false
    @Published var isLoadMoreLoading = false
    @Published private(set) var savedIds: Set<String> = []

    private var pendingIds: [String] = []
    private var canLoadMore = true
    private var isRefreshing = false

    private let getSavedNewsCategoriesUseCase: GetSavedNewsCategoriesUseCaseProtocol
    private let getSavedNewsByIdsUseCase: GetSavedNewsByIdsUseCaseProtocol
    private let toggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol

    init(
        getSavedNewsCategoriesUseCase: GetSavedNewsCategoriesUseCaseProtocol = GetSavedNewsCategoriesUseCase(),
        getSavedNewsByIdsUseCase: GetSavedNewsByIdsUseCaseProtocol,
        toggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol = ToggleSavedNewsUseCase()
    ) {
        self.getSavedNewsCategoriesUseCase = getSavedNewsCategoriesUseCase
        self.getSavedNewsByIdsUseCase = getSavedNewsByIdsUseCase
        self.toggleSavedNewsUseCase = toggleSavedNewsUseCase
    }

    func loadInitial() async {
        refreshCategories()
        guard let category = selectedCategory else { return }
        resetPagination(for: category)
        isLoading = true
        await fetchNextBatch(categoryId: category.id)
        isLoading = false
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        refreshCategories()
        guard let category = selectedCategory else {
            articles = []
            isRefreshing = false
            return
        }
        resetPagination(for: category)
        isLoading = true
        await fetchNextBatch(categoryId: category.id)
        isLoading = false
        isRefreshing = false
    }

    func selectCategory(_ category: SportCategory) async {
        guard selectedCategory != category else { return }
        selectedCategory = category
        resetPagination(for: category)
        isLoading = true
        await fetchNextBatch(categoryId: category.id)
        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, !isLoadMoreLoading, canLoadMore,
              let category = selectedCategory else { return }
        isLoadMoreLoading = true
        await fetchNextBatch(categoryId: category.id)
        isLoadMoreLoading = false
    }

    func isSaved(_ id: String) -> Bool {
        savedIds.contains(id)
    }

    @discardableResult
    func toggleSave(news: SportNews, categoryId: String, categoryName: String) -> Bool {
        let isNowSaved = toggleSavedNewsUseCase.execute(
            id: news.id,
            categoryId: categoryId,
            categoryName: categoryName
        )
        savedIds = toggleSavedNewsUseCase.savedIds()

        if !isNowSaved {
            articles.removeAll { $0.id == news.id }
            refreshCategoriesAfterUnsave()
        }

        return isNowSaved
    }

    private func refreshCategories() {
        categories = getSavedNewsCategoriesUseCase.execute()
        savedIds = toggleSavedNewsUseCase.savedIds()

        if let selected = selectedCategory,
           categories.contains(where: { $0.id == selected.id }) {
            return
        }
        selectedCategory = categories.first
    }

    private func refreshCategoriesAfterUnsave() {
        let previousId = selectedCategory?.id
        categories = getSavedNewsCategoriesUseCase.execute()

        if let previousId,
           categories.contains(where: { $0.id == previousId }) {
            return
        }

        selectedCategory = categories.first
        if let category = selectedCategory {
            resetPagination(for: category)
            Task { await loadInitial() }
        } else {
            articles = []
            pendingIds = []
            canLoadMore = false
        }
    }

    private func resetPagination(for category: SportCategory) {
        pendingIds = SavedNewsStorage.items(for: category.id).map(\.id)
        articles = []
        canLoadMore = !pendingIds.isEmpty
    }

    private func fetchNextBatch(categoryId: String) async {
        let batch = Array(pendingIds.prefix(Self.batchSize))
        guard !batch.isEmpty else {
            canLoadMore = false
            return
        }
        pendingIds.removeFirst(batch.count)

        do {
            let result = try await getSavedNewsByIdsUseCase.execute(ids: batch, categoryId: categoryId)
            result.notFound.forEach { SavedNewsStorage.remove(id: $0) }

            let articleMap = Dictionary(uniqueKeysWithValues: result.articles.map { ($0.id, $0) })
            let ordered = batch.compactMap { articleMap[$0] }
            articles.append(contentsOf: ordered)
            canLoadMore = !pendingIds.isEmpty
        } catch {
            pendingIds = batch + pendingIds
            print("Error loading saved news: \(error.localizedDescription)")
        }
    }
}
