//
//  ProfileView.swift
//  sportnews
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var debugUnlockManager: DebugUnlockManager

    var body: some View {
        VStack(spacing: 0) {
            profileHeader
            buildBody
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var profileHeader: some View {
        HStack {
            Text("SportNews")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(AppColors.accentRed)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(AppColors.backgroundCard)
    }

    private var buildBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                interfaceSection
                systemSection
                utilitySection
                versionFooter
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var interfaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("CẤU HÌNH GIAO DIỆN")

            VStack(spacing: 0) {
                navigationRow(
                    icon: "circle.lefthalf.filled",
                    title: "Chế độ giao diện",
                    subtitle: viewModel.appearanceMode.title
                ) {
                    router.showAppearanceSettings()
                }

                sectionDivider

                navigationRow(
                    icon: "iphone",
                    title: "Tin tức đã lưu"
                ) {
                    router.showSavedNews()
                }
            }
            .background(AppColors.backgroundCard)
            .cornerRadius(12)
        }
    }

    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("CẤU HÌNH HỆ THỐNG")

            VStack(spacing: 0) {
                navigationRow(
                    icon: "bell",
                    title: "Cài đặt thông báo"
                ) {
                    router.showNotificationSettings()
                }
            }
            .background(AppColors.backgroundCard)
            .cornerRadius(12)
        }
    }

    private var utilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("THÔNG TIN TIỆN ÍCH")

            VStack(spacing: 0) {
                navigationRow(
                    icon: "exclamationmark.circle",
                    title: "Đóng góp ý kiến / Hỗ trợ"
                ) {
                    router.showFeedbackSupport()
                }
            }
            .background(AppColors.backgroundCard)
            .cornerRadius(12)
        }
    }

    private var versionFooter: some View {
        Text(viewModel.appVersion)
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .onTapGesture {
                debugUnlockManager.registerVersionTap()
            }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }

    private var sectionDivider: some View {
        Divider()
            .padding(.leading, 56)
    }

    private func iconBadge(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(AppColors.accentRed)
            .frame(width: 32, height: 32)
            .background(AppColors.accentRedSoft)
            .clipShape(Circle())
    }

    private func navigationRow(
        icon: String,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconBadge(icon)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.accentRed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
