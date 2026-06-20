//
//  SiteAdBlockScript.swift
//  sportnews
//

import WebKit

enum SiteAdBlockScript {
    private static let profiles = SiteAdBlockProfileRegistry.all

    static let earlyGuard = WKUserScript(
        source: buildEarlyGuardSource(),
        injectionTime: .atDocumentStart,
        forMainFrameOnly: false
    )

    static let earlyCSS = WKUserScript(
        source: buildEarlyCSSSource(),
        injectionTime: .atDocumentStart,
        forMainFrameOnly: false
    )

    static let main = WKUserScript(
        source: buildMainSource(),
        injectionTime: .atDocumentEnd,
        forMainFrameOnly: false
    )

    private static func buildEarlyGuardSource() -> String {
        let guardedProfiles = profiles.filter(\.enablesEarlyScriptGuard)
        let hostChecks = guardedProfiles.map { profile in
            "if (/\(profile.hostPattern)/i.test(location.hostname)) return true;"
        }.joined(separator: "\n            ")

        let scriptPatterns = guardedProfiles
            .flatMap(\.blockedScriptPatterns)
            .joined(separator: "|")

        return """
        (function() {
            function shouldGuard() {
                \(hostChecks)
                return false;
            }

            if (!shouldGuard()) return;
            if (window.__sportnewsEarlyGuard) return;
            window.__sportnewsEarlyGuard = true;

            var blockedPattern = /\(scriptPatterns)/i;

            function blockScriptNode(node) {
                if (!node || node.tagName !== 'SCRIPT') return false;
                var src = node.getAttribute('src') || node.src || '';
                if (!blockedPattern.test(src || '')) return false;
                node.type = 'javascript/blocked';
                node.removeAttribute('src');
                try { node.remove(); } catch (e) {}
                return true;
            }

            function patchNodeInsertion(proto) {
                var appendChild = proto.appendChild;
                proto.appendChild = function(child) {
                    blockScriptNode(child);
                    return appendChild.call(this, child);
                };
                var insertBefore = proto.insertBefore;
                proto.insertBefore = function(child, ref) {
                    blockScriptNode(child);
                    return insertBefore.call(this, child, ref);
                };
            }

            patchNodeInsertion(Node.prototype);
            document.querySelectorAll('script[src]').forEach(blockScriptNode);

            new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType !== 1) return;
                        blockScriptNode(node);
                        if (node.querySelectorAll) {
                            node.querySelectorAll('script[src]').forEach(blockScriptNode);
                        }
                    });
                });
            }).observe(document.documentElement, { childList: true, subtree: true });
        })();
        """
    }

    private static func buildEarlyCSSSource() -> String {
        let profileBlocks = profiles
            .filter { !$0.earlyCSSRules.isEmpty }
            .map { profile in
                let css = profile.earlyCSSRules.joined(separator: " ")
                return """
                if (/\(profile.hostPattern)/i.test(location.hostname)) {
                    injectCSS('\(profile.jsString(css))', 'sportnews-adblock-early-\(profile.profileId)');
                }
                """
            }
            .joined(separator: "\n            ")

        return """
        (function() {
            function injectCSS(css, styleId) {
                if (document.getElementById(styleId)) return;
                var style = document.createElement('style');
                style.id = styleId;
                style.textContent = css;
                (document.head || document.documentElement).appendChild(style);
            }

            \(profileBlocks)
        })();
        """
    }

    private static func buildMainSource() -> String {
        let globalSelectors = SiteAdBlockProfile.globalAdSelectors.joined(separator: ", ")
        let profileDefinitions = profiles
            .map(\.profileJavaScriptDefinitions)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n            ")

        let profileRunBlocks = profiles.map { profile in
            """
            if (/\(profile.hostPattern)/i.test(location.hostname)) {
                \(profile.profileRunScript)
            }
            """
        }.joined(separator: "\n\n                ")

        return """
        (function() {
            var globalSelectors = '\(globalSelectors)';

            function hideElement(el) {
                el.style.setProperty('display', 'none', 'important');
                el.style.setProperty('height', '0', 'important');
                el.style.setProperty('max-height', '0', 'important');
                el.style.setProperty('visibility', 'hidden', 'important');
                el.style.setProperty('overflow', 'hidden', 'important');
                el.style.setProperty('padding', '0', 'important');
                el.style.setProperty('margin', '0', 'important');
            }

            function getArticleTitle() {
                return document.getElementById('title_detail')
                    || document.querySelector('h1.title-detail');
            }

            function getArticleContent() {
                return document.getElementById('content_detail')
                    || document.querySelector('article.fck_detail')
                    || document.querySelector('.fck_detail');
            }

            function isProtectedArticleElement(el) {
                if (!el || el.nodeType !== 1) return false;
                var title = getArticleTitle();
                var content = getArticleContent();
                var description = document.querySelector('.page-detail .description, p.description');
                if (title && (el === title || el.contains(title))) return true;
                if (content && (el === content || el.contains(content))) return true;
                if (description && (el === description || el.contains(description))) return true;
                return false;
            }

            function safeHideElement(el) {
                if (!el || el.nodeType !== 1) return;
                if (isProtectedArticleElement(el)) return;
                hideElement(el);
            }

            function injectStyle(selectors, styleId) {
                if (document.getElementById(styleId)) return;
                var rules = selectors.split(',').map(function(selector) {
                    return selector.trim() + '{display:none!important;height:0!important;max-height:0!important;visibility:hidden!important;overflow:hidden!important;padding:0!important;margin:0!important;}';
                }).join('');
                var style = document.createElement('style');
                style.id = styleId;
                style.textContent = rules;
                (document.head || document.documentElement).appendChild(style);
            }

            function hideMatching(root, selectors) {
                try {
                    var nodes = (root || document).querySelectorAll(selectors);
                    for (var i = 0; i < nodes.length; i++) {
                        hideElement(nodes[i]);
                    }
                } catch (e) {}
            }

            function isArticleReady() {
                var content = getArticleContent();
                if (!content) return false;
                var text = (content.innerText || content.textContent || '').replace(/\\s+/g, ' ').trim();
                return text.length > 30;
            }

            \(profileDefinitions)

            function run() {
                injectStyle(globalSelectors, 'sportnews-adblock-global');
                hideMatching(document, globalSelectors);

                \(profileRunBlocks)
            }

            function scheduleRun() {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(run, isArticleReady() ? 400 : 120);
            }

            run();

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', run);
            }
            window.addEventListener('load', function() {
                run();
                setTimeout(run, 300);
            });

            var debounceTimer;
            var observer = new MutationObserver(function(mutations) {
                for (var i = 0; i < mutations.length; i++) {
                    if (mutations[i].addedNodes.length > 0) {
                        scheduleRun();
                        return;
                    }
                }
            });

            function startObserver() {
                var target = document.body || document.documentElement;
                if (target) {
                    observer.observe(target, { childList: true, subtree: true });
                }
            }

            if (document.body) {
                startObserver();
            } else {
                document.addEventListener('DOMContentLoaded', startObserver);
            }
        })();
        """
    }
}

