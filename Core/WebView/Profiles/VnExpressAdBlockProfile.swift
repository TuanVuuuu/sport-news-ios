//
//  VnExpressAdBlockProfile.swift
//  sportnews
//

import Foundation

final class VnExpressAdBlockProfile: SiteAdBlockProfile {
    override var profileId: String { "vnexpress" }

    override var hostPattern: String { "(^|\\.)vnexpress\\.net$" }

    override var enablesEarlyScriptGuard: Bool { true }

    override var blockedScriptPatterns: [String] {
        [
            "aj\\d+\\.online", "admicro\\.vn\\/cms\\/Arf", "s\\.admicro\\.vn",
            "googletagservices\\.com", "securepubads\\.g\\.doubleclick\\.net",
            "pagead2\\.googlesyndication\\.com"
        ]
    }

    override var adSelectors: [String] {
        [
            "ins[data-key]", "ins.adsbygoogle",
            "div[id^=\"zone-ads-\"]", "div[id^=\"ad-zone-\"]",
            "div[id^=\"sis_\"]", "[id^=\"sis_\"]",
            ".banner-ads", ".inner_ads", ".text_ads", ".section_ads_300x250",
            "#TOP_BANNER", "#banner_top", ".box_quangcao",
            ".lazier", "[id^=\"_detail_\"]", "[id^=\"_box_\"]",
            "[class*=\"admFloating\"]", "[id*=\"admFloating\"]", "[id*=\"FloatingBanner\"]",
            "[class*=\"balloon\"]", "[id*=\"balloon\"]",
            ".wrap-banner-dudoan", ".box-category-ads",
            "div[data-component-type=\"tin_xemthem\"]", "#gtx-trans"
        ]
    }

    override var earlyCSSRules: [String] {
        readerLayoutRules + adHideRules
    }

    override var readerCSSRules: [String] { readerLayoutRules }

    override var overlayKeywords: [String] {
        [
            "quảng cáo", "quang cao", "voucher", "sale", "50%",
            "đội vô địch", "doi vo dich", "dự đoán", "du doan"
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
            return content.closest('.sidebar-1')
                || content.closest('.page-detail')
                || content.closest('main');
        }

        function trimArticle_\(profileId)() {
            var content = document.querySelector('article.fck_detail, .fck_detail');
            if (!content) return;

            hideMatching(content, [
                '.inner_ads', '.box_quangcao', '.banner-ads', 'ins[data-key]',
                'div[data-component-type="tin_xemthem"]', '#gtx-trans'
            ].join(','));

            var articleEnd = document.getElementById('article-end');
            if (articleEnd) {
                var afterEnd = articleEnd.nextElementSibling;
                while (afterEnd) {
                    safeHideElement(afterEnd);
                    afterEnd = afterEnd.nextElementSibling;
                }
            }

            var afterArticle = content.nextElementSibling;
            while (afterArticle) {
                safeHideElement(afterArticle);
                afterArticle = afterArticle.nextElementSibling;
            }

            var articleRoot = resolveArticleRoot_\(profileId)(content);
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

            document.querySelectorAll(
                '.page-detail.middle-detail, .page-detail.bottom-detail, footer, .footer'
            ).forEach(function(el) {
                safeHideElement(el);
            });
        }

        function hideFixedOverlays_\(profileId)() {
            var keywords = [\(overlayKeywords.map { "'\(jsString($0))'" }.joined(separator: ", "))];
            var title = getArticleTitle();
            var content = getArticleContent();
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
                var hasClose = !!el.querySelector(
                    '[class*="close"], [class*="Close"], .btn-close, .x, button'
                );
                var matchKeyword = keywords.some(function(keyword) {
                    return text.indexOf(keyword) !== -1;
                });

                if (hasClose || matchKeyword || (isSmallFloating && isOnRightEdge && isHighLayer)) {
                    hideElement(el);
                }
            }

            document.querySelectorAll('.start_sticky .box_embed_video, .start_sticky .embed-container').forEach(function(el) {
                if (content && content.contains(el)) return;
                hideElement(el);
            });
        }

        function scrollToTitle_\(profileId)() {
            var title = getArticleTitle();
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
            "header, .top-header, .wrap-main-nav,",
            "section#banner_top, #TOP_BANNER, .social_pin, .sidebar-2,",
            ".page-detail.middle-detail, .page-detail.bottom-detail,",
            "footer, .footer, .topbar-sticky,",
            ".wrap-banner-dudoan, #box_comment_vne, .section-comment,",
            ".lazier, [id^=\"_detail_\"], [id^=\"_box_\"], .box-category__list-news,",
            ".page-detail .breadcrumb{display:none!important;}",
            "h1.title-detail, p.description, article.fck_detail, .fck_detail{",
            "display:block!important;visibility:visible!important;opacity:1!important;",
            "height:auto!important;max-height:none!important;overflow:visible!important;}",
            ".sidebar-1{max-width:100%!important;width:100%!important;padding:0 16px!important;}",
            "body, .page-detail .container{background:#fcfaf6!important;",
            "padding-top:0!important;margin-top:0!important;}"
        ]
    }

    private var adHideRules: [String] {
        [
            "ins[data-key], ins.adsbygoogle, div[id^=\"zone-ads-\"], div[id^=\"ad-zone-\"],",
            "div[id^=\"sis_\"], .banner-ads, .inner_ads, .text_ads, .section_ads_300x250,",
            "#TOP_BANNER, #banner_top, .box_quangcao, .lazier, .wrap-banner-dudoan,",
            "[class*=\"admFloating\"], [id*=\"admFloating\"]",
            "{display:none!important;height:0!important;max-height:0!important;",
            "visibility:hidden!important;overflow:hidden!important;padding:0!important;margin:0!important;}"
        ]
    }
}
