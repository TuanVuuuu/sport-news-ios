//
//  AppearanceSettingsView.swift
//  sportnews
//

import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            buildBody
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

            Text("CHẾ ĐỘ GIAO DIỆN")
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
    }

    private var buildBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(AppearanceMode.allCases) { mode in
                    appearanceOptionCard(mode)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private func appearanceOptionCard(_ mode: AppearanceMode) -> some View {
        let isSelected = viewModel.appearanceMode == mode

        return Button {
            viewModel.selectAppearanceMode(mode)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(mode.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textOnAccent)
                        .frame(width: 24, height: 24)
                        .background(AppColors.accentRed)
                        .clipShape(Circle())
                }
            }
            .padding(16)
            .background(AppColors.backgroundCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accentRed : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
