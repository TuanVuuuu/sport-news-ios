//
//  NotificationFrequency.swift
//  sportnews
//

import Foundation

enum NotificationFrequency: Int, CaseIterable, Identifiable {
    case onePerDay = 1
    case twoPerDay = 2
    case threePerDay = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .onePerDay:
            return "Tối đa 1 thông báo / ngày"
        case .twoPerDay:
            return "Tối đa 2 thông báo / ngày"
        case .threePerDay:
            return "Tối đa 3 thông báo / ngày (Mặc định)"
        }
    }

    var subtitle: String {
        subtitle(timeSlots: [])
    }

    func subtitle(timeSlots: [NotificationTimeSlot]) -> String {
        guard !timeSlots.isEmpty else {
            return legacySubtitle
        }

        let allowedSlots = allowedTimeSlots(from: timeSlots)
        let labels = allowedSlots.map { slot in
            "\(slot.label) (\(slot.startHour)h - \(slot.endHour)h)"
        }

        switch self {
        case .onePerDay:
            return "Chỉ gửi vào khung giờ \(labels.joined(separator: ", ")). Phù hợp để tổng hợp tin nhanh cuối ngày."
        case .twoPerDay:
            return "Gửi vào khung giờ \(labels.joined(separator: " và ")). Cập nhật tin đầu ngày và cuối ngày."
        case .threePerDay:
            return "Gửi đầy đủ vào các khung giờ \(labels.joined(separator: " + ")). Đảm bảo không bỏ lỡ diễn biến nóng."
        }
    }

    static func availableCases(limit: Int) -> [NotificationFrequency] {
        allCases.filter { $0.rawValue <= max(1, limit) }
    }

    private var legacySubtitle: String {
        switch self {
        case .onePerDay:
            return "Chỉ gửi vào khung giờ Tối (17h - 22h). Phù hợp để tổng hợp tin nhanh cuối ngày."
        case .twoPerDay:
            return "Gửi vào khung giờ Sáng (6h - 11h) và Tối (17h - 22h). Cập nhật tin đầu ngày và cuối ngày."
        case .threePerDay:
            return "Gửi đầy đủ vào các khung giờ Sáng + Trưa + Tối. Đảm bảo không bỏ lỡ diễn biến nóng."
        }
    }

    private func allowedTimeSlots(from timeSlots: [NotificationTimeSlot]) -> [NotificationTimeSlot] {
        let allowedIds: [String]
        switch self {
        case .onePerDay:
            allowedIds = ["evening"]
        case .twoPerDay:
            allowedIds = ["morning", "evening"]
        case .threePerDay:
            allowedIds = timeSlots.map(\.id)
        }

        return allowedIds.compactMap { id in
            timeSlots.first { $0.id == id }
        }
    }
}
