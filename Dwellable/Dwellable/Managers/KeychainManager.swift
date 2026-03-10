import Foundation

class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.dwellable.app"
    private let isRunningTests = NSClassFromString("XCTest") != nil

    func save(_ value: String, forKey key: String) -> Bool {
        // Skip Keychain operations during XCUI tests to avoid blocking
        if isRunningTests {
            return true
        }

        guard let data = value.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieve(forKey key: String) -> String? {
        // Skip Keychain operations during XCUI tests to avoid blocking
        if isRunningTests {
            return nil
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(forKey key: String) -> Bool {
        // Skip Keychain operations during XCUI tests to avoid blocking
        if isRunningTests {
            return true
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
