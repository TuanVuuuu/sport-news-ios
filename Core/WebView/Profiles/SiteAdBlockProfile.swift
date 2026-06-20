//
//  SiteAdBlockProfile.swift
//  sportnews
//

import Foundation

class SiteAdBlockProfile {
    var profileId: String { "base" }

    /// JS regex source, e.g. `(^|\\.)thethao247\\.vn$`
    var hostPattern: String { "" }

    var enablesEarlyScriptGuard: Bool { false }

    var blockedScriptPatterns: [String] { [] }

    var adSelectors: [String] { [] }

    var earlyCSSRules: [String] { [] }

    var readerCSSRules: [String] { [] }

    var overlayKeywords: [String] { [] }

    /// JS function definitions specific to this site.
    var profileJavaScriptDefinitions: String { "" }

    /// JS statements executed when this profile is active.
    var profileRunScript: String { "" }

    static let globalAdSelectors: [String] = [
        ".ad", ".ads", ".advertisement", ".banner-ad", ".google-auto-placed",
        "[class*=\"ad-banner\"]", "[class*=\"ad-slot\"]", "[class*=\"ad-box\"]",
        "[id*=\"ad-banner\"]", "[id*=\"google_ads\"]", "[id*=\"div-gpt-ad\"]",
        "[class*=\"gpt-ad\"]", "[class*=\"admicro\"]", "[id*=\"admicro\"]",
        "[class*=\"box-ads\"]", "[class*=\"box-qc\"]", "[class*=\"quangcao\"]",
        "[class*=\"banner-top\"]", "[class*=\"banner-bottom\"]", "[class*=\"sticky-ads\"]",
        "[class*=\"floating-ads\"]", "[class*=\"ads-native\"]", "[class*=\"native-ads\"]",
        "[id*=\"zone-ads\"]", "[class*=\"zone-ads\"]", "[data-ad]", "[data-ads]",
        "[data-adslot]", "[class*=\"taboola\"]", "[id*=\"taboola\"]",
        "[class*=\"outbrain\"]", "[id*=\"outbrain\"]",
        "iframe[src*=\"doubleclick\"]", "iframe[src*=\"googlesyndication\"]",
        "iframe[src*=\"admicro\"]", "iframe[src*=\"gammassp\"]",
        "iframe[src*=\"admixer\"]", "iframe[src*=\"taboola\"]",
        "iframe[src*=\"outbrain\"]", "iframe[src*=\"mgid\"]", "iframe[src*=\"aj1047\"]"
    ]

    func joinedSelectors(_ selectors: [String]) -> String {
        selectors.joined(separator: ", ")
    }

    func jsString(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }

    func jsRegexSource(_ patterns: [String]) -> String {
        patterns.joined(separator: "|")
    }
}
