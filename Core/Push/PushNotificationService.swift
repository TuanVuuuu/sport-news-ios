//
//  PushNotificationService.swift
//  sportnews
//

import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

enum PushNotificationError: LocalizedError {
    case permissionDenied
    case missingFCMToken

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Người dùng chưa cấp quyền thông báo."
        case .missingFCMToken:
            return "Không lấy được FCM token."
        }
    }
}

@MainActor
final class PushNotificationService {
    static let shared = PushNotificationService()

    private let deviceIdStore: DeviceIdStoreProtocol
    private let registerDeviceUseCase: RegisterDeviceUseCaseProtocol

    private(set) var fcmToken: String?
    private var pendingOpenArticle: (highlightId: String, title: String?)?
    var onOpenArticle: ((String, String?) -> Void)?

    init(
        deviceIdStore: DeviceIdStoreProtocol = DeviceIdStore.shared,
        registerDeviceUseCase: RegisterDeviceUseCaseProtocol = RegisterDeviceUseCase()
    ) {
        self.deviceIdStore = deviceIdStore
        self.registerDeviceUseCase = registerDeviceUseCase
    }

    func processColdStartNotification(_ userInfo: [AnyHashable: Any]?) {
        guard let userInfo else { return }
        handlePayload(PushNotificationPayload(userInfo: userInfo))
    }

    func bootstrapOnLaunch() async {
        NotificationSettingsStorage.ensureDefaultsIfNeeded()

        guard NotificationSettingsStorage.loadEnabled() else { return }

        let preferences = NotificationSettingsStorage.currentPreferences()

        do {
            try await requestAuthorizationAndRegister(preferences: preferences)
            NotificationSettingsStorage.save(
                enabled: true,
                frequency: preferences.frequency
            )
        } catch PushNotificationError.permissionDenied {
            NotificationSettingsStorage.save(
                enabled: false,
                frequency: preferences.frequency
            )
        } catch {
            print("[Push] Bootstrap failed: \(error.localizedDescription)")
        }
    }

    func requestAuthorizationAndRegister(preferences: DevicePreferences?) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        var isAuthorized = settings.authorizationStatus == .authorized

        if settings.authorizationStatus == .notDetermined {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        }

        guard isAuthorized else {
            throw PushNotificationError.permissionDenied
        }

        UIApplication.shared.registerForRemoteNotifications()
        try await registerWithBackend(preferences: preferences)
        return true
    }

    func registerWithBackend(preferences: DevicePreferences?) async throws {
        let token = try await resolveFCMToken()
        _ = try await registerDeviceUseCase.execute(
            deviceId: deviceIdStore.deviceId,
            fcmToken: token,
            preferences: preferences
        )
    }

    func handleTokenRefresh(_ token: String?) async {
        guard let token else { return }
        fcmToken = token
        guard isPushEnabledLocally else { return }

        do {
            try await registerWithBackend(preferences: currentLocalPreferences())
        } catch {
            print("[Push] Token refresh register failed: \(error.localizedDescription)")
        }
    }

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let payload = PushNotificationPayload(userInfo: response.notification.request.content.userInfo)
        handlePayload(payload)
    }

    func bindNavigation(handler: @escaping (String, String?) -> Void) {
        onOpenArticle = handler
        flushPendingNavigation()
    }

    private func handlePayload(_ payload: PushNotificationPayload) {
        guard payload.clickAction == "OPEN_ARTICLE",
              let highlightId = payload.highlightId,
              !highlightId.isEmpty else {
            return
        }

        if payload.isTest {
            print("[Push] Test notification: \(highlightId)")
        }

        if let onOpenArticle {
            onOpenArticle(highlightId, payload.title)
        } else {
            pendingOpenArticle = (highlightId, payload.title)
        }
    }

    private func flushPendingNavigation() {
        guard let pending = pendingOpenArticle, let onOpenArticle else { return }
        pendingOpenArticle = nil
        onOpenArticle(pending.highlightId, pending.title)
    }

    private func resolveFCMToken() async throws -> String {
        if let fcmToken {
            return fcmToken
        }

        for attempt in 0..<10 {
            if let token = try? await Messaging.messaging().token(), !token.isEmpty {
                fcmToken = token
                return token
            }

            if attempt < 9 {
                try await Task.sleep(nanoseconds: 500_000_000)
            }
        }

        throw PushNotificationError.missingFCMToken
    }

    private var isPushEnabledLocally: Bool {
        NotificationSettingsStorage.loadEnabled()
    }

    private func currentLocalPreferences() -> DevicePreferences {
        NotificationSettingsStorage.currentPreferences()
    }
}
