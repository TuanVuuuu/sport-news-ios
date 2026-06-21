//
//  FeedbackMetadataProvider.swift
//  sportnews
//

import Foundation
import UIKit

struct FeedbackDeviceInfo {
    let appVersion: String
    let osVersion: String
    let platform: String
}

enum FeedbackMetadataProvider {
    static func currentDeviceInfo() -> FeedbackDeviceInfo {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let osVersion = "iOS \(UIDevice.current.systemVersion)"

        return FeedbackDeviceInfo(
            appVersion: version,
            osVersion: osVersion,
            platform: "ios"
        )
    }
}
