//
//  HomeViewModel.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var newsList: [SportNews] = []
    @Published var isLoading = false
    @Published var isLoadMoreLoading = false
    
    // Lưu danh sách Object Category từ API đổ về
    @Published var categories: [SportCategory] = []
    @Published var selectedCategory: SportCategory?
    
    // Lịch thi đấu World Cup
    @Published var worldCupSchedule: WorldCupSchedule?
    
    var nearestUpcomingFixtureDay: FixtureScheduleDay? {
        worldCupSchedule?.nearestUpcomingDay()
    }
    
    // Quản lý phân trang
    private var currentPage = 1
    private var canLoadMore = true
    private var isRefreshing = false
    
    // Logic: Lấy tin đầu tiên làm Banner nổi bật
    var featuredNews: SportNews? {
        return newsList.first
    }
    
    // Danh sách tin dòng nhỏ phía dưới (Bỏ tin đầu làm Banner)
    var filteredNews: [SportNews] {
        guard newsList.count > 1 else { return [] }
        return Array(newsList.dropFirst())
    }
    
    private let getHomeNewsUseCase: GetHomeNewsUseCaseProtocol
    private let getHomeCategoriesUseCase: GetHomeCategoriesUseCaseProtocol
    private let getWorldCupFixturesUseCase: GetWorldCupFixturesUseCaseProtocol
    
    init(
        getHomeNewsUseCase: GetHomeNewsUseCaseProtocol,
        getHomeCategoriesUseCase: GetHomeCategoriesUseCaseProtocol,
        getWorldCupFixturesUseCase: GetWorldCupFixturesUseCaseProtocol
    ) {
        self.getHomeNewsUseCase = getHomeNewsUseCase
        self.getHomeCategoriesUseCase = getHomeCategoriesUseCase
        self.getWorldCupFixturesUseCase = getWorldCupFixturesUseCase
    }
    
    func initializeHomeData() async {
        isLoading = true
        currentPage = 1
        canLoadMore = true

        do {
            try await fetchAndApplyHomeData()
        } catch {
            print("🚨 Lỗi khởi tạo dữ liệu Home: \(error)")
        }
        isLoading = false
    }

    func refreshHomeData() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        currentPage = 1
        canLoadMore = true

        do {
            try await fetchAndApplyHomeData()
        } catch {
            print("🚨 Lỗi refresh Home: \(error)")
        }
        isRefreshing = false
    }

    private func fetchAndApplyHomeData() async throws {
        let categoryParam = selectedCategory?.id.isEmpty == true ? nil : selectedCategory?.id

        async let categoriesTask = getHomeCategoriesUseCase.execute()
        async let newsTask = getHomeNewsUseCase.execute(page: 1, category: categoryParam)
        async let fixturesTask = getWorldCupFixturesUseCase.execute(leagueId: 1)

        let fetchedCategories = try await categoriesTask
        let allTab = SportCategory(id: "", name: "Tất cả")
        categories = [allTab] + fetchedCategories

        if selectedCategory == nil {
            selectedCategory = allTab
        }

        newsList = try await newsTask
        worldCupSchedule = try await fixturesTask
    }
    
    // Hàm được kích hoạt khi người dùng click đổi Tab ngang danh mục
    func selectCategory(_ category: SportCategory) async {
        guard selectedCategory != category else { return }
        selectedCategory = category
        
        // Reset phân trang và tải lại từ đầu
        isLoading = true
        currentPage = 1
        canLoadMore = true
        newsList = []
        
        do {
            // Nếu id là "" (Tất cả) thì truyền nil lên API
            let categoryParam = category.id.isEmpty ? nil : category.id
            self.newsList = try await getHomeNewsUseCase.execute(page: currentPage, category: categoryParam)
        } catch {
            print("🚨 Lỗi đổi danh mục: \(error)")
        }
        isLoading = false
    }
    
    // Hàm tải trang tiếp theo (Load More)
    func loadMoreNews() async {
        guard !isLoading && !isLoadMoreLoading && !isRefreshing && canLoadMore else { return }
        
        isLoadMoreLoading = true
        let nextPage = currentPage + 1
        print("🚀 [ViewModel] Đang load more trang: \(nextPage) cho danh mục: \(selectedCategory?.name ?? "")")
        
        do {
            let categoryParam = selectedCategory?.id.isEmpty == true ? nil : selectedCategory?.id
            let newPageNews = try await getHomeNewsUseCase.execute(
                page: nextPage,
                category: categoryParam
            )
            
            if newPageNews.isEmpty {
                canLoadMore = false
            } else {
                self.newsList.append(contentsOf: newPageNews)
                self.currentPage = nextPage
            }
        } catch {
            print("🚨 Lỗi load more: \(error.localizedDescription)")
            canLoadMore = false
        }
        isLoadMoreLoading = false
    }
}
