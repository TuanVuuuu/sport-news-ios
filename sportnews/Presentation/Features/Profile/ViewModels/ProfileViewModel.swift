//
//  ProfileViewModel.swift
//  sportnews
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var appearanceMode: AppearanceMode {
        didSet {
            appearanceMode.save()
        }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "SportNews Version \(version)"
    }

    init() {
        appearanceMode = AppearanceMode.loadStoredValue()
    }

    func selectAppearanceMode(_ mode: AppearanceMode) {
        appearanceMode = mode
    }
}
