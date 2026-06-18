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

    var id: String {
        switch self {
        case .newsDetail(let news):
            return "news-\(news.id)"
        case .discoverSectionList(let section):
            return "discover-section-\(section.id)"
        case .worldCupFixtures:
            return "world-cup-fixtures"
        }
    }

    var presentation: NavigationPresentation {
        switch self {
        case .newsDetail:
            return .fullScreen
        case .discoverSectionList, .worldCupFixtures:
            return .push
        }
    }
}

enum NavigationPresentation {
    case push // Dùng để chuyển trang
    case fullScreen // Dùng để hiển thị modal
    case sheet // Dùng để hiển thị sheet
}
