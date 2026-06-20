//
//  DiscoverView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack (spacing: 0) {
            discoverHeader
            
            buildBody
        }
        .background(AppColors.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard viewModel.sections.isEmpty else { return }
            await viewModel.loadKeywordsSuggestions()
            await viewModel.loadDiscoverData()
        }
    }
    
    // MARK: - Body Views
    private var buildBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                searchBarInput
                
                quickTagsSection
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    discoverSectionsList
                }
            }.padding(.vertical, 16)
        }
    }
    
    private var discoverSectionsList: some View {
        LazyVStack(spacing: 24) {
            ForEach(viewModel.sections) { section in
                VStack(spacing: 12) {
                    HStack {
                        Text(section.title.uppercased())
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Button {
                            router.showDiscoverSectionList(section)
                        } label: {
                            Text("Xem tất cả >").font(.system(size: 14)).foregroundColor(AppColors.accentRed)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(section.articles) { news in
                                DiscoverCardItem(news: news)
                                    .frame(width: 220)
                                    .onTapGesture {
                                        router.showNewsDetail(news)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var quickTagsSection: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(viewModel.keywordSuggestions) { tag in
                Button {
                    viewModel.selectedSearchText(text: tag.keyword)
                    Task {
                        await viewModel.searchDiscoverByKeyword(text: viewModel.searchText)
                    }
                } label: {
                    Text(tag.keyword)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColors.surfaceMuted)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // MARK: - Subviews
    private var discoverHeader: some View {
        HStack {
            Text("SportNews")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(AppColors.accentRed)
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.accentRed)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
    }
    
    private var searchBarInput: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Tìm kiếm giải đấu, đội bóng, vận động viên", text: $viewModel.searchText)
                .font(.system(size: 14))
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.searchDiscoverByKeyword(
                            text: viewModel.searchText
                        )
                    }
                }
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    Task {
                        await viewModel.loadDiscoverData()
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain) // tránh style mặc định của Button
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.surfaceMuted)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    
    
}

struct DiscoverCardItem: View {
    let news: SportNews
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NewsThumbnailView(
                imageUrl: news.imageUrl,
                blurHash: news.thumbnailBlurHash,
                fallbackColor: Color.gray.opacity(0.1)
            )
            .frame(height: 110).frame(maxWidth: .infinity).cornerRadius(8).clipped()
            
            Text(news.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(news.source) • \(news.timeAgo)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}
