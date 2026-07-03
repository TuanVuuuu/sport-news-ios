//
//  NotificationService.swift
//  NotificationServiceExtension
//

import FirebaseMessaging
import UniformTypeIdentifiers
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo
        logUserInfo(userInfo)

        if attachImageManually(to: bestAttemptContent, userInfo: userInfo) {
            NSLog("[PushNSE] Manual image attach succeeded")
            contentHandler(bestAttemptContent)
            return
        }

        NSLog("[PushNSE] Manual attach failed, delegating to Firebase extension helper")
        Messaging.serviceExtension().populateNotificationContent(
            bestAttemptContent,
            withContentHandler: contentHandler
        )
    }

    override func serviceExtensionTimeWillExpire() {
        NSLog("[PushNSE] Time will expire")
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    @discardableResult
    private func attachImageManually(
        to content: UNMutableNotificationContent,
        userInfo: [AnyHashable: Any]
    ) -> Bool {
        guard let imageURLString = PushNotificationImageURL.resolve(from: userInfo),
              let imageURL = URL(string: imageURLString),
              let attachment = Self.downloadAttachment(from: imageURL) else {
            NSLog("[PushNSE] Could not resolve or download image URL")
            return false
        }

        content.attachments = [attachment]
        return true
    }

    private func logUserInfo(_ userInfo: [AnyHashable: Any]) {
        let keys = userInfo.keys.map { String(describing: $0) }.sorted().joined(separator: ", ")
        NSLog("[PushNSE] Invoked. userInfo keys: %@", keys)

        let aps = userInfo["aps"] as? [String: Any]
        NSLog("[PushNSE] aps.mutable-content = %@", String(describing: aps?["mutable-content"]))

        if let image = PushNotificationImageURL.resolve(from: userInfo) {
            NSLog("[PushNSE] Resolved image URL: %@", image)
        } else {
            NSLog("[PushNSE] No image URL resolved from userInfo")
        }
    }

    private static func downloadAttachment(from url: URL) -> UNNotificationAttachment? {
        var request = URLRequest(url: url)
        request.timeoutInterval = 25

        let semaphore = DispatchSemaphore(value: 0)
        var downloadedData: Data?
        var mimeType: String?
        var downloadError: Error?

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            downloadError = error

            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode) else {
                return
            }

            mimeType = httpResponse.mimeType
            downloadedData = data
        }.resume()

        _ = semaphore.wait(timeout: .now() + 25)

        if let downloadError {
            NSLog("[PushNSE] Download error: %@", downloadError.localizedDescription)
            return nil
        }

        guard let data = downloadedData, !data.isEmpty else {
            NSLog("[PushNSE] Download returned empty data")
            return nil
        }

        let fileExtension = fileExtension(for: url, mimeType: mimeType)
        let localURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileExtension)

        do {
            try data.write(to: localURL)
            let typeHint = typeHint(for: fileExtension)
            return try UNNotificationAttachment(
                identifier: "image",
                url: localURL,
                options: typeHint.map { [UNNotificationAttachmentOptionsTypeHintKey: $0] }
            )
        } catch {
            NSLog("[PushNSE] Attachment error: %@", error.localizedDescription)
            return nil
        }
    }

    private static func fileExtension(for url: URL, mimeType: String?) -> String {
        if !url.pathExtension.isEmpty {
            return url.pathExtension
        }

        switch mimeType?.lowercased() {
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/webp":
            return "webp"
        default:
            return "jpg"
        }
    }

    private static func typeHint(for fileExtension: String) -> String? {
        switch fileExtension.lowercased() {
        case "png":
            return UTType.png.identifier
        case "gif":
            return UTType.gif.identifier
        case "webp":
            return UTType.webP.identifier
        default:
            return UTType.jpeg.identifier
        }
    }
}
