//
//  DeviceIdStore.swift
//  sportnews
//

import Foundation
import Security

protocol DeviceIdStoreProtocol {
    var deviceId: String { get }
}

final class DeviceIdStore: DeviceIdStoreProtocol {
    static let shared = DeviceIdStore()

    private static let service = "com.vunt.sportnews.device"
    private static let account = "device_id"

    private init() {}

    var deviceId: String {
        if let stored = readFromKeychain() {
            return stored
        }

        let newId = UUID().uuidString
        saveToKeychain(newId)
        return newId
    }

    private func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.service,
            kSecAttrAccount as String: Self.account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty else {
            return nil
        }

        return value
    }

    private func saveToKeychain(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }

        deleteFromKeychain()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.service,
            kSecAttrAccount as String: Self.account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.service,
            kSecAttrAccount as String: Self.account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
