//
//  NotificationSettingsView.swift
//  sportnews
//

import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationSettingsViewModel
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

            Text("CÀI ĐẶT THÔNG BÁO")
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Button("Lưu") {
                viewModel.saveSettings()
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppColors.accentRed)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
    }

    private var buildBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                breakingNewsCard
                frequencySection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var breakingNewsCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nhận tin tức nổi bật")
                    .font(.system(size: 16, weight: .bold))
                Text("Nhận thông báo về các sự kiện thể thao chấn động và chuyển nhượng bom tấn.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: $viewModel.isBreakingNewsEnabled)
                .labelsHidden()
                .tint(AppColors.accentRed)
        }
        .padding(16)
        .background(AppColors.backgroundCard)
        .cornerRadius(12)
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TẦN SUẤT NHẬN TIN")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.accentRed)
                .padding(.horizontal, 4)

            ForEach(NotificationFrequency.allCases) { frequency in
                frequencyOptionCard(frequency)
            }
        }
    }

    private func frequencyOptionCard(_ frequency: NotificationFrequency) -> some View {
        let isSelected = viewModel.selectedFrequency == frequency

        return Button {
            viewModel.selectFrequency(frequency)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(frequency.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(frequency.subtitle)
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
