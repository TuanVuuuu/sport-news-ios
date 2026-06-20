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
        switch self {
        case .onePerDay:
            return "Chỉ gửi vào khung giờ Tối (17h - 22h). Phù hợp để tổng hợp tin nhanh cuối ngày."
        case .twoPerDay:
            return "Gửi vào khung giờ Sáng (6h - 11h) và Tối (17h - 22h). Cập nhật tin đầu ngày và cuối ngày."
        case .threePerDay:
            return "Gửi đầy đủ vào các khung giờ Sáng + Trưa + Tối. Đảm bảo không bỏ lỡ diễn biến nóng."
        }
    }
}
