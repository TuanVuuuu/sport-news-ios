//
//  AppTabs.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

enum AppTab: Hashable, CaseIterable {
    case home
    case discover
    case profile

    var title: String {
        switch self {
        case .home:     return "Trang chủ"
        case .discover: return "Khám phá"
        case .profile:  return "Cá nhân"
        }
    }

    var systemImage: String {
        switch self {
        case .home:     return "house.fill"
        case .discover: return "safari.fill"
        case .profile:  return "person.fill"
        }
    }
}
