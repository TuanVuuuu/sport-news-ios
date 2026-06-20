//
//  WebViewAdBlocker.swift
//  sportnews
//

import WebKit

final class WebViewAdBlocker {
    static let shared = WebViewAdBlocker()

    private let ruleListIdentifier = "SportNewsAdBlockRulesV4"
    private var cachedRuleList: WKContentRuleList?
    private var isCompiling = false
    private var pendingCallbacks: [(WKContentRuleList?) -> Void] = []

    private init() {}

    var hasCachedRules: Bool { cachedRuleList != nil }

    func preload() {
        compileRulesIfNeeded { _ in }
    }

    func compileRulesIfNeeded(completion: @escaping (WKContentRuleList?) -> Void) {
        if let cachedRuleList {
            completion(cachedRuleList)
            return
        }

        pendingCallbacks.append(completion)
        guard !isCompiling else { return }
        isCompiling = true

        WKContentRuleListStore.default().lookUpContentRuleList(
            forIdentifier: ruleListIdentifier
        ) { [weak self] existing, lookupError in
            guard let self else { return }

            if let lookupError {
                print("[WebViewAdBlocker] lookUp error: \(lookupError.localizedDescription)")
            }

            if let existing {
                self.finish(with: existing)
                return
            }

            WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: self.ruleListIdentifier,
                encodedContentRuleList: Self.blockRulesJSON
            ) { ruleList, compileError in
                if let compileError {
                    print("[WebViewAdBlocker] compile error: \(compileError.localizedDescription)")
                }
                self.finish(with: ruleList)
            }
        }
    }

    func makeConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let contentController = config.userContentController

        if let cachedRuleList {
            contentController.add(cachedRuleList)
        }

        contentController.addUserScript(SiteAdBlockScript.earlyGuard)
        contentController.addUserScript(SiteAdBlockScript.earlyCSS)
        contentController.addUserScript(SiteAdBlockScript.main)
        return config
    }

    func addRules(to configuration: WKWebViewConfiguration, ruleList: WKContentRuleList) {
        configuration.userContentController.add(ruleList)
    }

    private func finish(with ruleList: WKContentRuleList?) {
        cachedRuleList = ruleList
        isCompiling = false

        let callbacks = pendingCallbacks
        pendingCallbacks = []
        callbacks.forEach { $0(ruleList) }
    }

    private static let blockRulesJSON = """
    [
      {
        "trigger": {
          "url-filter": ".*",
          "if-domain": [
            "*doubleclick.net",
            "*googlesyndication.com",
            "*googleadservices.com",
            "*google-analytics.com",
            "*googletagmanager.com",
            "*googletagservices.com",
            "*adservice.google.com",
            "*taboola.com",
            "*outbrain.com",
            "*criteo.com",
            "*facebook.net",
            "*scorecardresearch.com",
            "*quantserve.com",
            "*advertising.com",
            "*adnxs.com",
            "*rubiconproject.com",
            "*pubmatic.com",
            "*openx.net",
            "*smartadserver.com",
            "*media.net",
            "*amazon-adsystem.com",
            "*spotx.tv",
            "*spotxchange.com",
            "*freewheel.tv",
            "*teads.tv",
            "*mgid.com",
            "*revcontent.com",
            "*improvedigital.com",
            "*contextweb.com",
            "*lijit.com",
            "*sovrn.com"
          ]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": ".*",
          "if-domain": [
            "*admicro.vn",
            "*lg.admicro.vn",
            "*media.admicro.vn",
            "*media1.admicro.vn",
            "*gammassp.com",
            "*ambientdigitalgroup.com",
            "*admixer.net",
            "*innity.com",
            "*optad360.com",
            "*firstimpression.io",
            "*betweendigital.com",
            "*ucfunnel.com",
            "*aralego.com",
            "*adiiix.com",
            "*advalue.com.vn",
            "*adplus.vn",
            "*adpia.vn",
            "*adp.vn",
            "*genieesspv.jp",
            "*genieessp.com",
            "*adform.com",
            "*adtech.com",
            "*aolcloud.net",
            "*yieldmo.com",
            "*rhythmone.com",
            "*video.unrulymedia.com",
            "*aniview.com",
            "*vdo.ai",
            "*truvid.com",
            "*ampliffy.com",
            "*fout.jp",
            "*aj1047.online",
            "*aj1559.online"
          ]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://aj[0-9]+\\\\.online/",
          "resource-type": ["script", "image", "style-sheet", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": ".*",
          "resource-type": ["script"],
          "if-domain": [
            "*doubleclick.net",
            "*googlesyndication.com",
            "*googletagservices.com",
            "*admicro.vn",
            "*media1.admicro.vn",
            "*gammassp.com",
            "*admixer.net",
            "*taboola.com",
            "*outbrain.com",
            "*mgid.com",
            "*teads.tv",
            "*aj1047.online",
            "*aj1559.online"
          ]
        },
        "action": { "type": "block" }
      }
    ]
    """
}
