//
//  TheThao247AdBlockProfile.swift
//  sportnews
//

import Foundation

final class TheThao247AdBlockProfile: SiteAdBlockProfile {
    override var profileId: String { "thethao247" }

    override var hostPattern: String { "(^|\\.)thethao247\\.vn$" }

    override var enablesEarlyScriptGuard: Bool { true }

    override var blockedScriptPatterns: [String] {
        ["aj\\d+\\.online", "admicro\\.vn\\/cms\\/Arf"]
    }

    override var adSelectors: [String] {
        [
            ".as.ad", ".as.area", "div[as-id]", "ins[data-key]", "ins.adsbygoogle",
            "div[id^=\"zone-ads-\"]", "div[id^=\"ad-zone-\"]", ".m-ad-style",
            "ins.3b35b82f", "ins.982a9496",
            "[class*=\"admFloating\"]", "[id*=\"admFloating\"]", "[id*=\"FloatingBanner\"]",
            "[class*=\"balloon\"]", "[id*=\"balloon\"]"
        ]
    }

    override var earlyCSSRules: [String] {
        readerLayoutRules + adHideRules
    }

    override var readerCSSRules: [String] { readerLayoutRules }

    override var overlayKeywords: [String] {
        [
            "voucher", "lấy ngay", "lay ngay", "quảng cáo", "quang cao",
            "live -", "sale", "50%", "zocker"
        ]
    }

    override var profileJavaScriptDefinitions: String {
        """
        function applyReaderLayout_\(profileId)() {
            if (document.getElementById('sportnews-reader-\(profileId)')) return;
            var css = '\(jsString(readerLayoutRules.joined(separator: " ")))';
            var style = document.createElement('style');
            style.id = 'sportnews-reader-\(profileId)';
            style.textContent = css;
            (document.head || document.documentElement).appendChild(style);
        }

        function resolveArticleRoot_\(profileId)(content) {
            return content.closest('.detail_article')
                || content.closest('.col740')
                || content.closest('.block_white')
                || content.closest('main.main-detail')
                || content.closest('main.main_content')
                || content.closest('main');
        }

        function trimArticle_\(profileId)() {
            var content = document.getElementById('content_detail');
            if (!content) return;

            var articleRoot = resolveArticleRoot_\(profileId)(content);

            hideMatching(content, [
                '[class*="explus_related"]', '.news_related', '#comment_area',
                '.cmex', '.btn_feedback', '.popup_feedback'
            ].join(','));

            var afterContent = content.nextElementSibling;
            while (afterContent) {
                safeHideElement(afterContent);
                afterContent = afterContent.nextElementSibling;
            }

            if (!articleRoot) return;

            var node = content;
            while (node && node !== articleRoot) {
                var sibling = node.nextElementSibling;
                while (sibling) {
                    safeHideElement(sibling);
                    sibling = sibling.nextElementSibling;
                }
                node = node.parentElement;
            }

            var flexColumn = articleRoot.closest('.flex-1');
            if (flexColumn) {
                var columnSibling = flexColumn.nextElementSibling;
                while (columnSibling) {
                    safeHideElement(columnSibling);
                    columnSibling = columnSibling.nextElementSibling;
                }
            }

            document.querySelectorAll('footer, .footer_main').forEach(function(el) {
                safeHideElement(el);
            });
        }

        function hideBalloonZones_\(profileId)() {
            document.querySelectorAll('ins.982a9496').forEach(function(ins) {
                hideElement(ins);
                var zone = ins.closest('[as-id], [area-id], [code-id]');
                if (zone) hideElement(zone);
            });

            document.querySelectorAll('script[src]').forEach(function(script) {
                var src = script.getAttribute('src') || script.src || '';
                if (/aj\\d+\\.online/i.test(src)) {
                    script.remove();
                }
            });
        }

        function hideFixedOverlays_\(profileId)() {
            hideBalloonZones_\(profileId)();

            var keywords = [\(overlayKeywords.map { "'\(jsString($0))'" }.joined(separator: ", "))];
            var title = document.getElementById('title_detail');
            var content = document.getElementById('content_detail');
            var candidates = document.querySelectorAll('div, a, section, aside, span, ins, iframe');

            for (var i = 0; i < candidates.length; i++) {
                var el = candidates[i];
                if (title && (el === title || el.contains(title))) continue;
                if (content && (el === content || el.contains(content))) continue;

                var style = window.getComputedStyle(el);
                var position = style.position;
                if (position !== 'fixed' && position !== 'sticky' && position !== 'absolute') continue;

                var rect = el.getBoundingClientRect();
                if (rect.width < 28 || rect.height < 28) continue;
                if (rect.width > window.innerWidth * 0.92) continue;

                var zIndex = parseInt(style.zIndex, 10);
                var isHighLayer = !isNaN(zIndex) && zIndex >= 5;
                var isOnRightEdge = rect.right >= window.innerWidth - 24
                    && rect.left >= window.innerWidth * 0.45;
                var isSmallFloating = rect.width <= 180 && rect.height <= 180;

                var text = (el.innerText || el.textContent || '').toLowerCase().slice(0, 400);
                var img = el.querySelector('img');
                var imgAlt = img ? (img.alt || '').toLowerCase() : '';
                var hasClose = !!el.querySelector(
                    '[class*="close"], [class*="Close"], .btn-close, .x, button'
                );
                var matchKeyword = keywords.some(function(keyword) {
                    return text.indexOf(keyword) !== -1 || imgAlt.indexOf(keyword) !== -1;
                });

                if (hasClose || matchKeyword || (isSmallFloating && isOnRightEdge && isHighLayer)) {
                    hideElement(el);
                }
            }
        }

        function scrollToTitle_\(profileId)() {
            var title = document.getElementById('title_detail')
                || document.querySelector('.title-detail')
                || document.querySelector('.detail_article h1.big_title')
                || document.querySelector('.detail_article .big_title');
            if (!title) return;
            var top = title.getBoundingClientRect().top + window.pageYOffset - 8;
            window.scrollTo(0, Math.max(0, top));
        }
        """
    }

    override var profileRunScript: String {
        """
        applyReaderLayout_\(profileId)();
        injectStyle('\(jsString(joinedSelectors(adSelectors)))', 'sportnews-adblock-\(profileId)');
        hideMatching(document, '\(jsString(joinedSelectors(adSelectors)))');
        if (!isArticleReady()) return;
        trimArticle_\(profileId)();
        hideFixedOverlays_\(profileId)();
        if (!window.__sportnewsDidScroll_\(profileId)) {
            scrollToTitle_\(profileId)();
            window.__sportnewsDidScroll_\(profileId) = true;
        }
        """
    }

    private var readerLayoutRules: [String] {
        [
            "header, .header_main, .menu_main,",
            ".main-content > section, .main_content > .container.text-center.mt20,",
            ".main-detail .breadcrumb, .col740 > .breadcrumb{display:none!important;}",
            "footer, .footer_main, .breadcrumb_bottom, .news_suggest, .block_signature,",
            ".caption-more-detail, .box_latest_more, #loadMoreNews, .btn_loadmore,",
            ".popup_feedback, #comment_area, .cmex, .btn_feedback,",
            "[class*=\"explus_related\"], .news_related, .sticky_social,",
            ".detail_article .social_sharing_pc, .detail_article .social_sharing_mb,",
            ".detail_article .select-font-size, .select-font-size,",
            ".col300, .author-share-top .share_bottom,",
            ".detail_article #content_detail ~ *, .col740 #content_detail ~ *{display:none!important;}",
            ".block_white > section ~ section{display:none!important;}",
            "#title_detail, #content_detail, .title-detail{",
            "display:block!important;visibility:visible!important;opacity:1!important;",
            "height:auto!important;max-height:none!important;overflow:visible!important;}",
            "body, .main-content, .main_content, .main-detail .container.bg-white{",
            "padding-top:0!important;margin-top:0!important;}"
        ]
    }

    private var adHideRules: [String] {
        [
            "ins.982a9496, div[as-id]:has(ins.982a9496),",
            ".as.ad, .as.area, div[as-id], ins[data-key], ins.adsbygoogle,",
            "div[id^=\"zone-ads-\"], div[id^=\"ad-zone-\"], .m-ad-style,",
            "ins.3b35b82f, ins.982a9496",
            "{display:none!important;height:0!important;max-height:0!important;",
            "visibility:hidden!important;overflow:hidden!important;padding:0!important;margin:0!important;}"
        ]
    }
}
