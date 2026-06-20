//
//  DiscoverCategoryViewAllView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

import SwiftUI

struct DiscoverCategoryViewAllView: View {
    let section: DiscoverSection
    @ObservedObject var viewModel: DiscoverCategoryViewAllViewModel
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        VStack(spacing: 16) {
            contentsView
        }
        .padding(.horizontal)
        .background(AppColors.backgroundPrimary)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: section.id) {
            await viewModel.refreshNews(idCategory: section.id)
        }
    }
    
    private var contentsView: some View {
        let newsListForCategory = viewModel.news
        return ScrollView  {
            
            LazyVStack(spacing: 24) {
                ForEach(newsListForCategory) { new in
                    NewsRowView(news: new)
                        .onAppear {
                            let totalItems = newsListForCategory.count
                            
                            // Kích hoạt sớm khi người dùng cuộn tới phần tử thứ (Tổng - 4)
                            if totalItems >= 4 {
                                let triggerIndex = totalItems - 4
                                if new.id == newsListForCategory[triggerIndex].id {
                                    _Concurrency.Task {
                                        await viewModel.loadMoreNews(idCategory: section.id)
                                    }
                                }
                            } else if new.id == newsListForCategory.last?.id {
                                // Phòng trường hợp danh sách quá ngắn (ít hơn 3 phần tử), vẫn cho phép ăn theo item cuối
                                _Concurrency.Task {
                                    await viewModel.loadMoreNews(idCategory: section.id)
                                }
                            }
                        }
                        .onTapGesture {
                            router.showNewsDetail(new)
                        }
                }
                // Vòng xoay Loading khi kéo cuối trang (Load more)
                if viewModel.isLoadMoreLoading {
                    ProgressView()
                        .padding(.vertical, 12)
                }
            }
            .padding(.bottom, 16)
        }.refreshable {
            await viewModel.refreshNews(idCategory: section.id)
        }
    }
}
