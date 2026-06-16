//
//  NavigationFactory.swift
//  sportnews
//

import SwiftUI

@MainActor
final class NavigationFactory {
    let router: AppRouter
    
    private lazy var homeViewModel: HomeViewModel = {
        let repository = HomeRepository()
        return HomeViewModel(
            getHomeNewsUseCase: GetHomeNewsUseCase(repository: repository),
            getHomeCategoriesUseCase: GetHomeCategoriesUseCase(repository: repository)
        )
    }()
    
    private lazy var discoverViewModel: DiscoverViewModel = {
        let repository = DiscoverRepository()
        
        return DiscoverViewModel(
            getDiscoverUseCase: GetDiscoverUseCase(repository: repository),
            getKeywordSuggestionsUseCase: GetKeywordSuggestionsUseCase(
                repository: repository
            )
        )
    }()
    
    private lazy var discoverCategoryViewAllViewModel: DiscoverCategoryViewAllViewModel = {
        let homeRepository = HomeRepository()
        
        return DiscoverCategoryViewAllViewModel(
            getHomeNewsUseCase: GetHomeNewsUseCase(repository: homeRepository)
        )
    } ()
    
    init(router: AppRouter) {
        self.router = router
    }
    
    func makeHomeView() -> some View {
        HomeView(viewModel: self.homeViewModel)
    }
    
    func makeDiscoverView() -> some View {
        DiscoverView(viewModel: self.discoverViewModel)
    }
    
    func makeProfileView() -> some View {
        Text("Màn hình cá nhân")
    }
    
    @ViewBuilder
    func pushDestination(for route: AppRoute) -> some View {
        switch route {
        case .discoverSectionList(let section):
            DiscoverCategoryViewAllView(section: section, viewModel: self.discoverCategoryViewAllViewModel)
        case .newsDetail:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .newsDetail(let news):
            NewsDetailView(news: news)
        case .discoverSectionList:
            EmptyView()
        }
    }
}
