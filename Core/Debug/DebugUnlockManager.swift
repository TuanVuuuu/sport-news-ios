import Combine
import UIKit

@MainActor
final class DebugUnlockManager: ObservableObject {
    @Published private(set) var isNetworkDebugEnabled = false
    @Published var isNetworkConsolePresented = false

    private var homeTapCount = 0
    private var versionTapCount = 0
    private var lastTapDate: Date?

    private let homeTapTarget = 3
    private let versionTapTarget = 7
    private let tapResetInterval: TimeInterval = 60

    func registerHomeHeaderTap() {
        registerTap { homeTapCount += 1 }
    }

    func registerVersionTap() {
        registerTap { versionTapCount += 1 }
    }

    func showNetworkConsole() {
        guard isNetworkDebugEnabled else { return }
        isNetworkConsolePresented = true
    }

    private func registerTap(increment: () -> Void) {
        resetCountersIfNeeded()
        increment()
        lastTapDate = Date()
        evaluateUnlock()
    }

    private func resetCountersIfNeeded() {
        guard let lastTapDate else { return }
        guard Date().timeIntervalSince(lastTapDate) > tapResetInterval else { return }

        homeTapCount = 0
        versionTapCount = 0
        self.lastTapDate = nil
    }

    private func evaluateUnlock() {
        guard !isNetworkDebugEnabled else { return }
        guard homeTapCount >= homeTapTarget, versionTapCount >= versionTapTarget else { return }

        isNetworkDebugEnabled = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
