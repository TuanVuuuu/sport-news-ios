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
    
    @Published var news: [SportNews] = [] // Dùng cho màn xem tất cả
    
    // Quản lý phân trang
    private var currentPage = 1
    private var canLoadMore = true
    @Published var isLoadMoreLoading = false
    init(
        getHomeNewsUseCase: GetHomeNewsUseCase
    ) {
        self.getHomeNewsUseCase = getHomeNewsUseCase
    }
    
    func resetCurrentPage() {
        currentPage = 1
    }
    
    func refreshNews(idCategory: String) async {
        guard !isLoadMoreLoading else { return }
        
        do {
            resetCurrentPage()
            self.news = try await getHomeNewsUseCase.execute(
                page: 1,
                category: idCategory
            )
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func loadMoreNews(idCategory: String) async {
        guard  !isLoadMoreLoading && canLoadMore else { return
        }
        
        isLoadMoreLoading = true
        let nextPage = currentPage + 1
        do {
            let  newPageNews = try await getHomeNewsUseCase.execute(
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
