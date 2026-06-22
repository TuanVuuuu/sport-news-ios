//
//  LegalWebView.swift
//  sportnews
//

import SwiftUI
import WebKit

struct LegalWebView: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator {
        Coordinator(urlString: urlString)
    }

    func makeUIView(context: Context) -> WKWebView {
        if let prewarmedWebView = LegalWebViewPrewarmer.shared.takeWebView(for: urlString) {
            context.coordinator.attach(webView: prewarmedWebView, urlString: urlString)
            return prewarmedWebView
        }

        let webView = WKWebView(
            frame: .zero,
            configuration: LegalWebViewPrewarmer.shared.makeConfiguration()
        )
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.attach(webView: webView, urlString: urlString)
        context.coordinator.loadIfNeeded()
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

        init(urlString: String) {
            self.urlString = urlString
        }

        func attach(webView: WKWebView, urlString: String) {
            self.webView = webView
            self.urlString = urlString
            if let url = URL(string: urlString), webView.url == url {
                lastLoadedURL = url
            }
        }

        func loadIfNeeded() {
            guard let webView, let url = URL(string: urlString) else { return }
            guard lastLoadedURL != url else { return }

            lastLoadedURL = url
            webView.load(URLRequest(url: url))
        }
    }
}
