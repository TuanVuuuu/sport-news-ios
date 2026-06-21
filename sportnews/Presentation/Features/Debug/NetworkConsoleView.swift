import PulseUI
import SwiftUI

struct NetworkConsoleView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ConsoleView()
                .navigationTitle("Network Logs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Đóng") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct NetworkDebugFloatingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(AppColors.accentRed)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .accessibilityLabel("Mở network logs")
    }
}
