//
//  sportnewsApp.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 6/6/26.
//

import SwiftUI
import FirebaseCore

@main
struct SportNewsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        FirebaseApp.configure()
        _ = DeviceIdStore.shared.deviceId
        NotificationSettingsStorage.syncFromCloudIfNeeded()
        NotificationSettingsStorage.ensureDefaultsIfNeeded()
        KingfisherConfigurator.configure()
        WebViewAdBlocker.shared.preload()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
