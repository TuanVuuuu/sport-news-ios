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

    var id: String {
        switch self {
        case .newsDetail(let news):
            return "news-\(news.id)"
        case .discoverSectionList(let section):
            return "discover-section-\(section.id)"
        }
    }

    var presentation: NavigationPresentation {
        switch self {
        case .newsDetail:
            return .fullScreen
        case .discoverSectionList:
            return .push
        }
    }
}

enum NavigationPresentation {
    case push // Dùng để chuyển trang
    case fullScreen // Dùng để hiển thị modal
    case sheet // Dùng để hiển thị sheet
}
