//
//  SavedNewsView.swift
//  sportnews
//

import SwiftUI

struct SavedNewsView: View {
    @StateObject private var viewModel: SavedNewsViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var toastManager: ToastManager

    init(viewModel: SavedNewsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.categories.isEmpty {
                emptyState
            } else {
                categoryTabs
                savedNewsList
            }
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Tin tức đã lưu")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitial()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundColor(AppColors.accentRed)
            Text("Chưa có tin tức đã lưu")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories) { category in
                    CategoryTabButton(
                        category: category,
                        isSelected: viewModel.selectedCategory == category,
                        onTap: {
                            withAnimation(.spring()) {
                                _ = _Concurrency.Task {
                                    await viewModel.selectCategory(category)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private var savedNewsList: some View {
        if viewModel.isLoading && viewModel.articles.isEmpty {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else if viewModel.articles.isEmpty {
            VStack {
                Spacer()
                Text("Không còn bài trong danh mục này")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.articles) { news in
                        NewsRowView(
                            news: news,
                            isSaved: viewModel.isSaved(news.id),
                            onSaveToggle: {
                                handleSaveToggle(news: news)
                            },
                            onTap: {
                                router.showNewsDetail(news)
                            }
                        )
                        .onAppear {
                            let list = viewModel.articles
                            let totalItems = list.count
                            if totalItems >= 4 {
                                let triggerIndex = totalItems - 4
                                if news.id == list[triggerIndex].id {
                                    _Concurrency.Task {
                                        await viewModel.loadMore()
                                    }
                                }
                            } else if news.id == list.last?.id {
                                _Concurrency.Task {
                                    await viewModel.loadMore()
                                }
                            }
                        }
                    }

                    if viewModel.isLoadMoreLoading {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private func handleSaveToggle(news: SportNews) {
        guard let category = viewModel.selectedCategory else { return }
        let isSaved = viewModel.toggleSave(
            news: news,
            categoryId: category.id,
            categoryName: category.name
        )
        toastManager.show(isSaved ? "Đã lưu tin tức" : "Đã bỏ lưu tin tức")
    }
}
