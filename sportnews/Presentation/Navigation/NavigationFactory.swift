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
        let footballRepository = FootballRepository()
        return HomeViewModel(
            getHomeNewsUseCase: GetHomeNewsUseCase(repository: repository),
            getHomeCategoriesUseCase: GetHomeCategoriesUseCase(repository: repository),
            getWorldCupFixturesUseCase: GetWorldCupFixturesUseCase(repository: footballRepository)
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

    private lazy var profileViewModel = ProfileViewModel()

    private lazy var notificationSettingsViewModel = NotificationSettingsViewModel()
    
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
        ProfileView(viewModel: profileViewModel)
    }
    
    @ViewBuilder
    func pushDestination(for route: AppRoute) -> some View {
        switch route {
        case .discoverSectionList(let section):
            DiscoverCategoryViewAllView(
                section: section,
                getHomeNewsUseCase: GetHomeNewsUseCase(
                    repository: HomeRepository()
                )
            )
        case .worldCupFixtures(let schedule):
            WorldCupFixturesDetailView(schedule: schedule)
        case .notificationSettings:
            NotificationSettingsView(viewModel: notificationSettingsViewModel)
        case .appearanceSettings:
            AppearanceSettingsView(viewModel: profileViewModel)
        case .savedNews:
            SavedNewsView()
        case .feedbackSupport:
            FeedbackSupportView(viewModel: FeedbackSupportViewModel())
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
        case .worldCupFixtures:
            EmptyView()
        case .notificationSettings, .appearanceSettings, .savedNews, .feedbackSupport:
            EmptyView()
        }
    }
}
