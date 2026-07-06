//
//  DiscoverCategoryViewAllView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

import SwiftUI

struct DiscoverCategoryViewAllView: View {
    let section: DiscoverSection
    @StateObject private var viewModel: DiscoverCategoryViewAllViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var toastManager: ToastManager
    
    init(
        section: DiscoverSection,
        getHomeNewsUseCase: GetHomeNewsUseCase,
        toggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol = ToggleSavedNewsUseCase()
    ) {
        self.section = section
        _viewModel = StateObject(
            wrappedValue: DiscoverCategoryViewAllViewModel(
                getHomeNewsUseCase: getHomeNewsUseCase,
                toggleSavedNewsUseCase: toggleSavedNewsUseCase
            )
        )
    }
    
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
    
    @ViewBuilder
    private var contentsView: some View {
        let newsListForCategory = viewModel.news
        
        if viewModel.isLoading {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(newsListForCategory) { new in
                        NewsRowView(
                            news: new,
                            isSaved: viewModel.isSaved(new.id),
                            onSaveToggle: {
                                let isSaved = viewModel.toggleSave(
                                    news: new,
                                    categoryId: section.id,
                                    categoryName: section.title
                                )
                                toastManager.show(isSaved ? "Đã lưu tin tức" : "Đã bỏ lưu tin tức")
                            },
                            onTap: {
                                router.showNewsDetail(new)
                            }
                        )
                        .onAppear {
                            let totalItems = newsListForCategory.count
                            
                            if totalItems >= 4 {
                                let triggerIndex = totalItems - 4
                                if new.id == newsListForCategory[triggerIndex].id {
                                    _Concurrency.Task {
                                        await viewModel.loadMoreNews(idCategory: section.id)
                                    }
                                }
                            } else if new.id == newsListForCategory.last?.id {
                                _Concurrency.Task {
                                    await viewModel.loadMoreNews(idCategory: section.id)
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoadMoreLoading {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .padding(.bottom, 16)
            }
            .refreshable {
                await viewModel.refreshNews(idCategory: section.id)
            }
        }
    }
}
