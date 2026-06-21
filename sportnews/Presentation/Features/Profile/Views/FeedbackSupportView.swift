//
//  FeedbackSupportView.swift
//  sportnews
//

import SwiftUI

struct FeedbackSupportView: View {
    @ObservedObject var viewModel: FeedbackSupportViewModel
    @EnvironmentObject private var toastManager: ToastManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            formContent
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .alert("Thông báo", isPresented: isErrorPresented) {
            Button("Đóng", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
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
            .disabled(viewModel.isSubmitting)

            Spacer()

            Text("ĐÓNG GÓP Ý KIẾN")
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Button("Gửi") {
                Task {
                    if await viewModel.submitFeedback() {
                        toastManager.show(FeedbackSupportViewModel.successMessage)
                        dismiss()
                    }
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(viewModel.canSubmit ? AppColors.accentRed : .secondary)
            .disabled(!viewModel.canSubmit)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
    }

    private var formContent: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    typeSection
                    messageSection
                    contactSection
                    deviceInfoSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .disabled(viewModel.isSubmitting)

            if viewModel.isSubmitting {
                ProgressView()
            }
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("LOẠI PHẢN HỒI")

            ForEach(FeedbackType.allCases) { type in
                typeOptionCard(type)
            }
        }
    }

    private func typeOptionCard(_ type: FeedbackType) -> some View {
        let isSelected = viewModel.selectedType == type

        return Button {
            viewModel.selectType(type)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.accentRed)
                    .frame(width: 32, height: 32)
                    .background(AppColors.accentRedSoft)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(type.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(type.subtitle)
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

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("NỘI DUNG")

            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if viewModel.message.isEmpty {
                        Text("Mô tả chi tiết vấn đề hoặc ý kiến của bạn...")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                    }

                    TextEditor(text: $viewModel.message)
                        .font(.system(size: 15))
                        .frame(minHeight: 120)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .scrollContentBackground(.hidden)
                }

                HStack {
                    if !viewModel.message.isEmpty && !viewModel.isMessageValid {
                        Text("Tối thiểu \(FeedbackSupportViewModel.messageMinLength) ký tự")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.accentRed)
                    }

                    Spacer()

                    Text("\(viewModel.message.count)/\(FeedbackSupportViewModel.messageMaxLength)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(AppColors.backgroundCard)
            .cornerRadius(12)
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("EMAIL LIÊN HỆ (TUỲ CHỌN)")

            VStack(alignment: .leading, spacing: 6) {
                TextField("user@email.com", text: $viewModel.contact)
                    .font(.system(size: 15))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(16)
                    .background(AppColors.backgroundCard)
                    .cornerRadius(12)

                if !viewModel.contact.isEmpty && !viewModel.isContactValid {
                    Text("Email không hợp lệ")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.accentRed)
                        .padding(.horizontal, 4)
                } else {
                    Text("Để lại email nếu bạn muốn được phản hồi.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
        }
    }

    private var deviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isDeviceInfoExpanded.toggle()
                }
            } label: {
                HStack {
                    sectionTitle("THÔNG TIN THIẾT BỊ")
                    Spacer()
                    Image(systemName: viewModel.isDeviceInfoExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if viewModel.isDeviceInfoExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    deviceInfoRow("App", viewModel.deviceInfo.appVersion)
                    deviceInfoRow("Hệ điều hành", viewModel.deviceInfo.osVersion)
                    deviceInfoRow("Nền tảng", viewModel.deviceInfo.platform.uppercased())
                }
                .padding(16)
                .background(AppColors.backgroundCard)
                .cornerRadius(12)
            }

            Text("Thông tin thiết bị sẽ được gửi kèm để hỗ trợ nhanh hơn.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }

    private func deviceInfoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(AppColors.accentRed)
            .padding(.horizontal, 4)
    }
}
