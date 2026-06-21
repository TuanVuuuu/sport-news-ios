//
//  FeedbackSupportViewModel.swift
//  sportnews
//

import Foundation
import Combine

@MainActor
final class FeedbackSupportViewModel: ObservableObject {
    @Published var selectedType: FeedbackType = .bug
    @Published var message = "" {
        didSet {
            if message.count > Self.messageMaxLength {
                message = String(message.prefix(Self.messageMaxLength))
            }
        }
    }
    @Published var contact = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    static let successMessage = "Cảm ơn bạn đã gửi phản hồi. Chúng tôi sẽ xem xét sớm."
    @Published var isDeviceInfoExpanded = false

    let deviceInfo: FeedbackDeviceInfo

    private let deviceIdStore: DeviceIdStoreProtocol
    private let submitFeedbackUseCase: SubmitFeedbackUseCaseProtocol
    private let screen: String
    private let context: [String: String]

    static let messageMinLength = 10
    static let messageMaxLength = 1000

    var canSubmit: Bool {
        guard !isSubmitting else { return false }
        guard isMessageValid else { return false }
        guard isContactValid else { return false }
        return true
    }

    var isMessageValid: Bool {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= Self.messageMinLength && trimmed.count <= Self.messageMaxLength
    }

    var isContactValid: Bool {
        let trimmed = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return trimmed.contains("@") && trimmed.contains(".")
    }

    var deviceInfoSummary: String {
        "\(deviceInfo.appVersion) · \(deviceInfo.osVersion)"
    }

    init(
        screen: String = "FeedbackSupport",
        context: [String: String] = [:],
        deviceIdStore: DeviceIdStoreProtocol = DeviceIdStore.shared,
        submitFeedbackUseCase: SubmitFeedbackUseCaseProtocol = SubmitFeedbackUseCase()
    ) {
        self.screen = screen
        self.context = context
        self.deviceIdStore = deviceIdStore
        self.submitFeedbackUseCase = submitFeedbackUseCase
        self.deviceInfo = FeedbackMetadataProvider.currentDeviceInfo()
        self.contact = FeedbackContactStorage.load()
    }

    func selectType(_ type: FeedbackType) {
        selectedType = type
    }

    func submitFeedback() async -> Bool {
        guard canSubmit else { return false }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)

        let submission = FeedbackSubmission(
            type: selectedType,
            message: trimmedMessage,
            deviceId: deviceIdStore.deviceId,
            platform: deviceInfo.platform,
            appVersion: deviceInfo.appVersion,
            osVersion: deviceInfo.osVersion,
            screen: screen,
            context: context,
            contact: trimmedContact.isEmpty ? nil : trimmedContact
        )

        do {
            _ = try await submitFeedbackUseCase.execute(submission)

            if !trimmedContact.isEmpty {
                FeedbackContactStorage.save(trimmedContact)
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func resetForm() {
        selectedType = .bug
        message = ""
        errorMessage = nil
    }
}
