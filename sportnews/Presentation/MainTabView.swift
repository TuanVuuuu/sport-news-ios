//
//  MainTabView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import SwiftUI

struct MainTabView: View {
    private let homeView: HomeView
    private var discoverView: DiscoverView
    
    init() {
        self.homeView = Self.createHomeView()
        self.discoverView = Self.createDiscoverView()
    }
    
    private static func createHomeView() -> HomeView {
        let homeRepository = HomeRepository()
        
        let newsUseCase  = GetHomeNewsUseCase(repository: homeRepository)
        let categoriesUseCase = GetHomeCategoriesUseCase(repository: homeRepository)
        
        let viewModel = HomeViewModel(
            getHomeNewsUseCase: newsUseCase,
            getHomeCategoriesUseCase: categoriesUseCase
        )
        
        return HomeView(viewModel: viewModel)
    }
    
    private static func createDiscoverView() -> DiscoverView {
        let discoverRepository = DiscoverRepository()
        let discoverUseCase = GetDiscoverUseCase(repository: discoverRepository)
        let keywordSuggestionsUseCase = GetKeywordSuggestionsUseCase(repository: discoverRepository)
        let viewModel = DiscoverViewModel(
            getDiscoverUseCase: discoverUseCase,
            getKeywordSuggestionsUseCase: keywordSuggestionsUseCase
        )
        return DiscoverView(viewModel: viewModel)
    }
    
    var body: some View {
        TabView {
            homeView
                .tabItem {
                    Label("Trang chủ", systemImage: "house.fill")
                }
            
            discoverView
                .tabItem {
                    Label("Khám phá", systemImage: "safari.fill")
                }
            
            Text("Màn hình cá nhân")
                .tabItem {
                    Label("Cá nhân", systemImage: "person.fill")
                }
        }
        .accentColor(Color(red: 0.7, green: 0.1, blue: 0.1))
    }
}
