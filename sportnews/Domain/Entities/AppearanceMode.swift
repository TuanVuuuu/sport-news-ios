//
//  AppearanceMode.swift
//  sportnews
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "profile.appearanceMode"
    private static let legacyDarkModeKey = "profile.isDarkMode"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Hệ thống"
        case .light: return "Sáng"
        case .dark: return "Tối"
        }
    }

    var subtitle: String {
        switch self {
        case .system: return "Theo cài đặt thiết bị của bạn."
        case .light: return "Luôn hiển thị giao diện sáng."
        case .dark: return "Luôn hiển thị giao diện tối."
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static func loadStoredValue() -> AppearanceMode {
        let defaults = UserDefaults.standard

        if let raw = defaults.string(forKey: storageKey),
           let mode = AppearanceMode(rawValue: raw) {
            return mode
        }

        if defaults.object(forKey: legacyDarkModeKey) != nil {
            return defaults.bool(forKey: legacyDarkModeKey) ? .dark : .system
        }

        return .system
    }

    func save() {
        UserDefaults.standard.set(rawValue, forKey: Self.storageKey)
    }
}
