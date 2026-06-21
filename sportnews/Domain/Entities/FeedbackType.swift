//
//  FeedbackType.swift
//  sportnews
//

import Foundation

enum FeedbackType: String, CaseIterable, Identifiable {
    case bug
    case feedback
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bug: return "Báo lỗi"
        case .feedback: return "Góp ý"
        case .other: return "Khác"
        }
    }

    var subtitle: String {
        switch self {
        case .bug: return "App gặp sự cố hoặc crash."
        case .feedback: return "Đề xuất cải thiện trải nghiệm."
        case .other: return "Câu hỏi, hỗ trợ hoặc phản hồi khác."
        }
    }

    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feedback: return "lightbulb"
        case .other: return "ellipsis.circle"
        }
    }
}

struct FeedbackSubmission {
    let type: FeedbackType
    let message: String
    let deviceId: String
    let platform: String
    let appVersion: String
    let osVersion: String
    let screen: String
    let context: [String: String]
    let contact: String?
}

struct FeedbackResult: Equatable {
    let id: String
    let message: String
}

enum FeedbackAPIError: LocalizedError {
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .serverMessage(let message):
            return message
        }
    }
}
