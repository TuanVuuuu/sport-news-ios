//
//  AppRoute.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//
import Foundation

enum AppRoute: Hashable, Identifiable {
    case newsDetail(SportNews)
    case discoverSectionList(DiscoverSection)
    case worldCupFixtures(WorldCupSchedule)
    case notificationSettings
    case appearanceSettings
    case savedNews
    case feedbackSupport
    case privacyPolicy
    case termsOfUse

    var id: String {
        switch self {
        case .newsDetail(let news):
            return "news-\(news.id)"
        case .discoverSectionList(let section):
            return "discover-section-\(section.id)"
        case .worldCupFixtures:
            return "world-cup-fixtures"
        case .notificationSettings:
            return "notification-settings"
        case .appearanceSettings:
            return "appearance-settings"
        case .savedNews:
            return "saved-news"
        case .feedbackSupport:
            return "feedback-support"
        case .privacyPolicy:
            return "privacy-policy"
        case .termsOfUse:
            return "terms-of-use"
        }
    }

    var presentation: NavigationPresentation {
        switch self {
        case .newsDetail:
            return .fullScreen
        case .discoverSectionList, .worldCupFixtures, .notificationSettings, .appearanceSettings, .savedNews, .feedbackSupport, .privacyPolicy, .termsOfUse:
            return .push
        }
    }
}

enum NavigationPresentation {
    case push // Dùng để chuyển trang
    case fullScreen // Dùng để hiển thị modal
    case sheet // Dùng để hiển thị sheet
}
