//
//  PushNotificationImageURL.swift
//  sportnews
//

import Foundation

enum PushNotificationImageURL {
    /// Đọc URL ảnh từ userInfo FCM/APNs.
    /// `notification.image` trên FCM thường map sang `fcm_options.image` hoặc `gcm.notification.image`.
    static func resolve(from userInfo: [AnyHashable: Any]) -> String? {
        let directKeys = [
            "image_url",
            "imageUrl",
            "thumbnail_url",
            "image",
            "thumbnail",
            "gcm.notification.image",
            "gcm.notification.image_url",
        ]

        for key in directKeys {
            if let value = stringValue(userInfo[key]) {
                return value
            }
        }

        if let fcmOptions = userInfo["fcm_options"] {
            if let value = imageFromFCMOptions(fcmOptions) {
                return value
            }
        }

        if let googleOptions = userInfo["google.c.fcm_options"] {
            if let value = imageFromFCMOptions(googleOptions) {
                return value
            }
        }

        if let aps = userInfo["aps"] as? [String: Any],
           let fcmOptions = aps["fcm_options"] {
            if let value = imageFromFCMOptions(fcmOptions) {
                return value
            }
        }

        return nil
    }

    private static func imageFromFCMOptions(_ value: Any) -> String? {
        if let options = value as? [String: Any] {
            for key in ["image", "imageUrl", "image_url"] {
                if let image = stringValue(options[key]) {
                    return image
                }
            }
        }

        if let json = value as? String,
           let data = json.data(using: .utf8),
           let options = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for key in ["image", "imageUrl", "image_url"] {
                if let image = stringValue(options[key]) {
                    return image
                }
            }
        }

        return nil
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
}
