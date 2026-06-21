//
//  NotificationSettingsViewModel.swift
//  sportnews
//

import Foundation
import Combine

@MainActor
final class NotificationSettingsViewModel: ObservableObject {
    @Published var isBreakingNewsEnabled: Bool
    @Published var selectedFrequency: NotificationFrequency
    @Published var timeSlots: [NotificationTimeSlot] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let deviceIdStore: DeviceIdStoreProtocol
    private let pushService: PushNotificationService
    private let getSettingsUseCase: GetNotificationSettingsUseCaseProtocol
    private let getPreferencesUseCase: GetDevicePreferencesUseCaseProtocol
    private let updatePreferencesUseCase: UpdateDevicePreferencesUseCaseProtocol

    var availableFrequencies: [NotificationFrequency] {
        NotificationFrequency.availableCases(limit: maxPerDayLimit)
    }

    private var maxPerDayLimit = 3

    init(
        deviceIdStore: DeviceIdStoreProtocol = DeviceIdStore.shared,
        pushService: PushNotificationService = .shared,
        getSettingsUseCase: GetNotificationSettingsUseCaseProtocol = GetNotificationSettingsUseCase(),
        getPreferencesUseCase: GetDevicePreferencesUseCaseProtocol = GetDevicePreferencesUseCase(),
        updatePreferencesUseCase: UpdateDevicePreferencesUseCaseProtocol = UpdateDevicePreferencesUseCase()
    ) {
        self.deviceIdStore = deviceIdStore
        self.pushService = pushService
        self.getSettingsUseCase = getSettingsUseCase
        self.getPreferencesUseCase = getPreferencesUseCase
        self.updatePreferencesUseCase = updatePreferencesUseCase

        isBreakingNewsEnabled = NotificationSettingsStorage.loadEnabled()
        selectedFrequency = NotificationSettingsStorage.loadFrequency()
    }

    func loadSettings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let settings = try await getSettingsUseCase.execute()
            applySettings(from: settings)

            do {
                let record = try await getPreferencesUseCase.execute(deviceId: deviceIdStore.deviceId)
                applyPreferences(record.preferences)
            } catch NotificationAPIError.serverMessage(let message) where message.contains("Không tìm thấy") {
                applyPreferences(
                    .featured(
                        enabled: settings.defaultEnabled,
                        frequency: NotificationFrequency(rawValue: settings.defaultMaxPerDay) ?? .threePerDay
                    )
                )
            } catch {
                applyPreferences(NotificationSettingsStorage.currentPreferences())
            }

            cacheLocally()
        } catch {
            errorMessage = error.localizedDescription
            isBreakingNewsEnabled = NotificationSettingsStorage.loadEnabled()
            selectedFrequency = NotificationSettingsStorage.loadFrequency()
        }
    }

    func selectFrequency(_ frequency: NotificationFrequency) {
        guard isBreakingNewsEnabled else { return }
        selectedFrequency = frequency
    }

    func saveSettings() async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let preferences = DevicePreferences.featured(
            enabled: isBreakingNewsEnabled,
            frequency: selectedFrequency
        )

        do {
            if isBreakingNewsEnabled {
                try await pushService.requestAuthorizationAndRegister(preferences: preferences)
            } else {
                try await disablePushOnServer()
            }

            cacheLocally()
            return true
        } catch PushNotificationError.permissionDenied {
            isBreakingNewsEnabled = false
            errorMessage = PushNotificationError.permissionDenied.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func applySettings(from settings: NotificationSettings) {
        maxPerDayLimit = settings.maxPerDayLimit
        timeSlots = settings.timeSlots

        if !availableFrequencies.contains(selectedFrequency) {
            selectedFrequency = availableFrequencies.last ?? .threePerDay
        }
    }

    private func applyPreferences(_ preferences: DevicePreferences) {
        isBreakingNewsEnabled = preferences.enabled
        selectedFrequency = preferences.frequency

        if !availableFrequencies.contains(selectedFrequency) {
            selectedFrequency = availableFrequencies.last ?? .threePerDay
        }
    }

    private func disablePushOnServer() async throws {
        do {
            _ = try await updatePreferencesUseCase.execute(
                deviceId: deviceIdStore.deviceId,
                enabled: false,
                maxPerDay: nil,
                categories: nil
            )
        } catch NotificationAPIError.serverMessage(let message) where message.contains("Không tìm thấy") {
            return
        }
    }

    private func cacheLocally() {
        NotificationSettingsStorage.save(
            enabled: isBreakingNewsEnabled,
            frequency: selectedFrequency
        )
    }
}
