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

    func openArticleFromPush(highlightId: String, title: String? = nil) {
        if highlightId.hasPrefix("test://") {
            print("[Push] Test notification tapped: \(highlightId)")
            return
        }

        showNewsDetail(
            SportNews(
                id: highlightId,
                title: title ?? "Tin tức",
                source: "Thông báo",
                timeAgo: "",
                category: "Thể thao",
                imageUrl: "",
                thumbnailBlurHash: nil,
                isFeatured: true
            )
        )
    }

    func showDiscoverSectionList(_ section: DiscoverSection) {
        navigationPath.append(AppRoute.discoverSectionList(section))
    }
    
    func showWorldCupFixtures(_ schedule: WorldCupSchedule) {
        navigationPath.append(AppRoute.worldCupFixtures(schedule))
    }

    func showNotificationSettings() {
        navigationPath.append(AppRoute.notificationSettings)
    }

    func showAppearanceSettings() {
        navigationPath.append(AppRoute.appearanceSettings)
    }

    func showSavedNews() {
        navigationPath.append(AppRoute.savedNews)
    }

    func showFeedbackSupport() {
        navigationPath.append(AppRoute.feedbackSupport)
    }

    func dismissFullScreen() {
        fullScreenRoute = nil
    }
}
