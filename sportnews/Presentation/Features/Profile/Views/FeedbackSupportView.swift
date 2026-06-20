//
//  FeedbackSupportView.swift
//  sportnews
//

import SwiftUI

struct FeedbackSupportView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 40))
                .foregroundColor(AppColors.accentRed)
            Text("Tính năng đang được phát triển")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Đóng góp ý kiến / Hỗ trợ")
        .navigationBarTitleDisplayMode(.inline)
    }
}
