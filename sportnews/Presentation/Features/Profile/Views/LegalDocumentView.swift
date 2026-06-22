//
//  LegalDocumentView.swift
//  sportnews
//

import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let urlString: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            LegalWebView(urlString: urlString)
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(title.uppercased())
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
    }
}
