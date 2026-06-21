//
//  FeedbackEndpoint.swift
//  sportnews
//

import Foundation

enum FeedbackEndpoint: APIEndpoint {
    case submit(FeedbackSubmission)

    var path: String {
        "api/feedback"
    }

    var method: HTTPMethod {
        .post
    }

    var queryParameters: [String: Any]? {
        nil
    }

    var bodyParameters: [String: Any]? {
        guard case .submit(let submission) = self else { return nil }

        var body: [String: Any] = [
            "type": submission.type.rawValue,
            "message": submission.message,
            "device_id": submission.deviceId,
            "platform": submission.platform,
            "app_version": submission.appVersion,
            "os_version": submission.osVersion,
            "screen": submission.screen
        ]

        if !submission.context.isEmpty {
            body["context"] = submission.context
        }

        if let contact = submission.contact?.trimmingCharacters(in: .whitespacesAndNewlines),
           !contact.isEmpty {
            body["contact"] = contact
        }

        return body
    }
}
