//
//  MainTabView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import SwiftUI

struct MainTabView: View {
    private let homeView: HomeView
    
    init() {
        let homeRepository = HomeRepository()
        
        let newsUseCase  = GetHomeNewsUseCase(repository: homeRepository)
        let categoriesUseCase = GetHomeCategoriesUseCase(repository: homeRepository)
        
        let viewModel = HomeViewModel(
            getHomeNewsUseCase: newsUseCase,
            getHomeCategoriesUseCase: categoriesUseCase
        )
        
        self.homeView = HomeView(viewModel: viewModel)
    }
    
    var body: some View {
        TabView {
            homeView
                .tabItem {
                    Label("Trang chủ", systemImage: "house.fill")
                }
            
            Text("Màn hình khám phá")
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
