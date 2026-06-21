//
//  ToastManager.swift
//  sportnews
//

import SwiftUI
import Combine

@MainActor
final class ToastManager: ObservableObject {
    @Published private(set) var message: String?

    private var dismissTask: Task<Void, Never>?

    func show(_ message: String, duration: TimeInterval = 3) {
        dismissTask?.cancel()
        self.message = message

        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            if self.message == message {
                self.message = nil
            }
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        message = nil
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppColors.textOnAccent)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(AppColors.accentRed.opacity(0.95))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

struct ToastOverlayModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message = toastManager.message {
                    ToastView(message: message)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: toastManager.message)
    }
}

extension View {
    func toastOverlay(using toastManager: ToastManager) -> some View {
        modifier(ToastOverlayModifier(toastManager: toastManager))
    }
}
