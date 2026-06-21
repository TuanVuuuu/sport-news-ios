//
//  FeedbackContactStorage.swift
//  sportnews
//

import Foundation

enum FeedbackContactStorage {
    private static let storageKey = "feedback.contact.email"

    static func load() -> String {
        UserDefaults.standard.string(forKey: storageKey) ?? ""
    }

    static func save(_ email: String) {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: storageKey)
    }
}
