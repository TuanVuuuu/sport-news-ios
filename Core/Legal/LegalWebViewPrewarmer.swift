//
//  LegalWebViewPrewarmer.swift
//  sportnews
//

import WebKit

@MainActor
final class LegalWebViewPrewarmer {
    static let shared = LegalWebViewPrewarmer()

    private static let processPool = WKProcessPool()

    private var prewarmedViews: [String: WKWebView] = [:]
    private var prewarmingURLs: Set<String> = []

    private init() {}

    func prewarmAll() {
        prewarm(url: AppLegalURLs.privacyPolicy)
        prewarm(url: AppLegalURLs.termsOfUse)
    }

    func takeWebView(for urlString: String) -> WKWebView? {
        guard let webView = prewarmedViews.removeValue(forKey: urlString) else {
            return nil
        }

        prewarm(url: urlString)
        return webView
    }

    func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = Self.processPool
        return configuration
    }

    private func prewarm(url: String) {
        guard prewarmedViews[url] == nil,
              !prewarmingURLs.contains(url),
              let requestURL = URL(string: url) else {
            return
        }

        prewarmingURLs.insert(url)

        let webView = WKWebView(frame: .zero, configuration: makeConfiguration())
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: requestURL))

        prewarmedViews[url] = webView
        prewarmingURLs.remove(url)
    }
}
