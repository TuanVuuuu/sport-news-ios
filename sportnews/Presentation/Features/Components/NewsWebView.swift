//
//  NewsWebView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 8/6/26.
//

import SwiftUI
import WebKit

struct NewsWebView: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator {
        Coordinator(urlString: urlString)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WebViewAdBlocker.shared.makeConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true

        context.coordinator.webView = webView

        if WebViewAdBlocker.shared.hasCachedRules {
            context.coordinator.beginInitialLoad()
        } else {
            WebViewAdBlocker.shared.compileRulesIfNeeded { ruleList in
                if let ruleList {
                    WebViewAdBlocker.shared.addRules(to: webView.configuration, ruleList: ruleList)
                }
                context.coordinator.beginInitialLoad()
            }
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.urlString = urlString
        context.coordinator.loadIfNeeded()
    }

    final class Coordinator {
        var urlString: String
        weak var webView: WKWebView?
        private var lastLoadedURL: URL?
        private var hasStartedInitialLoad = false

        init(urlString: String) {
            self.urlString = urlString
        }

        func beginInitialLoad() {
            guard !hasStartedInitialLoad else { return }
            hasStartedInitialLoad = true
            loadIfNeeded()
        }

        func loadIfNeeded() {
            guard let webView, let url = Self.normalizedURL(from: urlString) else { return }
            guard lastLoadedURL != url else { return }

            lastLoadedURL = url
            webView.load(URLRequest(url: url))
        }

        static func normalizedURL(from urlString: String) -> URL? {
            guard var components = URLComponents(string: urlString) else { return nil }
            guard let host = components.host?.lowercased() else { return components.url }

            if host == "thethao247.vn" {
                components.host = "m.thethao247.vn"
            }

            return components.url
        }
    }
}
