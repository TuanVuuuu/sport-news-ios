//
//  PushNotificationPayload.swift
//  sportnews
//

import Foundation

struct PushNotificationPayload {
    let type: String?
    let highlightId: String?
    let clickAction: String?
    let articleCount: String?
    let categoryId: String?
    let isTest: Bool
    let title: String?
    let body: String?
    let imageUrl: String?

    init(userInfo: [AnyHashable: Any]) {
        type = Self.stringValue(userInfo["type"])
        highlightId = Self.stringValue(userInfo["highlight_id"])
        clickAction = Self.stringValue(userInfo["click_action"])
        articleCount = Self.stringValue(userInfo["article_count"])
        categoryId = Self.stringValue(userInfo["category_id"])
        isTest = Self.stringValue(userInfo["is_test"]) == "true"
        title = Self.stringValue(userInfo["title"]) ?? Self.alertTitle(from: userInfo)
        body = Self.stringValue(userInfo["body"]) ?? Self.alertBody(from: userInfo)
        imageUrl = PushNotificationImageURL.resolve(from: userInfo)
    }

    private static func stringValue(_ value: Any?) -> String? {
        switch value {
        case let string as String where !string.isEmpty:
            return string
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    private static func alertTitle(from userInfo: [AnyHashable: Any]) -> String? {
        guard let alert = alertDictionary(from: userInfo) else { return nil }
        return stringValue(alert["title"])
    }

    private static func alertBody(from userInfo: [AnyHashable: Any]) -> String? {
        if let alert = alertDictionary(from: userInfo) {
            return stringValue(alert["body"]) ?? stringValue(alert["title"])
        }

        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? String {
            return alert
        }

        return nil
    }

    private static func alertDictionary(from userInfo: [AnyHashable: Any]) -> [String: Any]? {
        guard let aps = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any] else {
            return nil
        }
        return alert
    }
}
