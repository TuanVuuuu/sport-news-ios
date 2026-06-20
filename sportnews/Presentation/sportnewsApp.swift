//
//  sportnewsApp.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 6/6/26.
//

import SwiftUI

@main
struct SportNewsApp: App {
    init() {
        KingfisherConfigurator.configure()
        WebViewAdBlocker.shared.preload()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
