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
    
    // Quản lý phân trang
    private var currentPage = 1
    private var canLoadMore = true
    
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
    private let getHomeCategoriesUseCase: GetHomeCategoriesUseCaseProtocol // Thêm UseCase mới
    
    // Nhận vào 2 UseCase thông qua Dependency Injection
    init(
        getHomeNewsUseCase: GetHomeNewsUseCaseProtocol,
        getHomeCategoriesUseCase: GetHomeCategoriesUseCaseProtocol
    ) {
        self.getHomeNewsUseCase = getHomeNewsUseCase
        self.getHomeCategoriesUseCase = getHomeCategoriesUseCase
    }
    
    // Hàm khởi tạo dữ liệu ban đầu cho màn hình Home
    func initializeHomeData() async {
        isLoading = true
        currentPage = 1
        canLoadMore = true
        
        do {
            // 1. Gọi API lấy danh mục trước
            let fetchedCategories = try await getHomeCategoriesUseCase.execute()
            
            // Tự chèn thêm Tab "Tất cả" vào đầu mảng với ID rỗng để Server hiểu là lấy tất cả
            let allTab = SportCategory(id: "", name: "Tất cả")
            self.categories = [allTab] + fetchedCategories
            
            // Nếu chưa chọn danh mục nào, mặc định chọn Tab "Tất cả"
            if self.selectedCategory == nil {
                self.selectedCategory = allTab
            }
            
            // 2. Gọi API lấy tin tức theo Category đang chọn
            self.newsList = try await getHomeNewsUseCase.execute(
                page: currentPage,
                category: selectedCategory?.id == "" ? nil : selectedCategory?.id
            )
            
        } catch {
            print("🚨 Lỗi khởi tạo dữ liệu Home: \(error)")
        }
        isLoading = false
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
        guard !isLoading && !isLoadMoreLoading && canLoadMore else { return }
        
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
