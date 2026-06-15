//
//  MainTabView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var router: AppRouter
    @State private var factory: NavigationFactory

    init() {
        let router = AppRouter()
        _router = StateObject(wrappedValue: router)
        _factory = State(initialValue: NavigationFactory(router: router))
    }

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            TabView(selection: $router.selectedTab) {
                factory.makeHomeView()
                    .tabItem {
                        Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
                    }
                    .tag(AppTab.home)

                factory.makeDiscoverView()
                    .tabItem {
                        Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage)
                    }
                    .tag(AppTab.discover)

                factory.makeProfileView()
                    .tabItem {
                        Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
                    }
                    .tag(AppTab.profile)
            }
            .accentColor(Color(red: 0.7, green: 0.1, blue: 0.1))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppRoute.self) { route in
                factory.pushDestination(for: route)
                    .environmentObject(router)
            }
        }
        .environmentObject(router)
        .fullScreenCover(item: $router.fullScreenRoute) { route in
            factory.destination(for: route)
                .environmentObject(router)
        }
    }
}
