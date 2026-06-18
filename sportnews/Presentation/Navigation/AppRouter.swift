//
//  AppRouter.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//
import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var navigationPath = NavigationPath()
    @Published var fullScreenRoute: AppRoute?

    func showNewsDetail(_ news: SportNews) {
        fullScreenRoute = .newsDetail(news)
    }

    func showDiscoverSectionList(_ section: DiscoverSection) {
        navigationPath.append(AppRoute.discoverSectionList(section))
    }
    
    func showWorldCupFixtures(_ schedule: WorldCupSchedule) {
        navigationPath.append(AppRoute.worldCupFixtures(schedule))
    }

    func dismissFullScreen() {
        fullScreenRoute = nil
    }
}
