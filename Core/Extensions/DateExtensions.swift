//
//  DateExtentions.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

import Foundation

extension Date {
    /// VD: "Sat, 06 Jun 2026 19:11:43 +0700"
    static func fromRFC2822(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: string)
    }
    
    /// "3 giờ trước", "2 ngày trước", ...
    func relativeTimeString(referenceDate: Date = Date()) -> String {
        guard self <= referenceDate else { return "Vừa xong" }
        let calendar = Calendar.current
        if let years = calendar.dateComponents([.year], from: self, to: referenceDate).year, years >= 1 {
            return "\(years) năm trước"
        }
        if let months = calendar.dateComponents([.month], from: self, to: referenceDate).month, months >= 1 {
            return "\(months) tháng trước"
        }
        if let weeks = calendar.dateComponents([.weekOfYear], from: self, to: referenceDate).weekOfYear, weeks >= 1 {
            return "\(weeks) tuần trước"
        }
        if let days = calendar.dateComponents([.day], from: self, to: referenceDate).day, days >= 1 {
            return "\(days) ngày trước"
        }
        if let hours = calendar.dateComponents([.hour], from: self, to: referenceDate).hour, hours >= 1 {
            return "\(hours) giờ trước"
        }
        if let minutes = calendar.dateComponents([.minute], from: self, to: referenceDate).minute, minutes >= 1 {
            return "\(minutes) phút trước"
        }
        return "Vừa xong"
    }
}

// MARK: - Tiện ích cho chuỗi thời gian từ API
extension String {
    func toRelativeTimeString() -> String {
        guard !isEmpty, let date = Date.fromRFC2822(self) else {
            return "Vừa xong"
        }
        return date.relativeTimeString()
    }
}

