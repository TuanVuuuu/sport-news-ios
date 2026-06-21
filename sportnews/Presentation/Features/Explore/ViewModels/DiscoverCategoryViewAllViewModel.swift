//
//  DiscoverCategoryViewAllViewModel.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 16/6/26.
//

import Foundation
import Combine

@MainActor
class DiscoverCategoryViewAllViewModel: ObservableObject {
    private let getHomeNewsUseCase: GetHomeNewsUseCase
    private let toggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol

    @Published var news: [SportNews] = []
    @Published private(set) var savedIds: Set<String> = []

    private var currentPage = 1
    private var canLoadMore = true
    @Published var isLoadMoreLoading = false

    init(
        getHomeNewsUseCase: GetHomeNewsUseCase,
        toggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol = ToggleSavedNewsUseCase()
    ) {
        self.getHomeNewsUseCase = getHomeNewsUseCase
        self.toggleSavedNewsUseCase = toggleSavedNewsUseCase
        self.savedIds = toggleSavedNewsUseCase.savedIds()
    }

    func resetCurrentPage() {
        currentPage = 1
    }

    func refreshSavedIds() {
        savedIds = toggleSavedNewsUseCase.savedIds()
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
        return isNowSaved
    }

    func refreshNews(idCategory: String) async {
        guard !isLoadMoreLoading else { return }

        do {
            resetCurrentPage()
            canLoadMore = true
            self.news = try await getHomeNewsUseCase.execute(
                page: 1,
                category: idCategory
            )
            refreshSavedIds()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func loadMoreNews(idCategory: String) async {
        guard !isLoadMoreLoading && canLoadMore else { return }

        isLoadMoreLoading = true
        let nextPage = currentPage + 1
        do {
            let newPageNews = try await getHomeNewsUseCase.execute(
                page: nextPage,
                category: idCategory
            )

            if newPageNews.isEmpty {
                canLoadMore = false
            } else {
                self.news.append(contentsOf: newPageNews)
                self.currentPage = nextPage
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        isLoadMoreLoading = false
    }
}
