//
//  SavedNewsView.swift
//  sportnews
//

import SwiftUI

struct SavedNewsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundColor(AppColors.accentRed)
            Text("Chưa có tin tức đã lưu")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Tin tức đã lưu")
        .navigationBarTitleDisplayMode(.inline)
    }
}
