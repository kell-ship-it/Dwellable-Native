import Foundation
import LocalAuthentication

class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.dwelly.app"
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

    // MARK: - Biometric-Protected Storage (Face ID login)

    /// Saves a value behind `kSecAccessControlBiometryCurrentSet` — the OS itself requires
    /// a successful Face ID/Touch ID check before this item can ever be read back, and the
    /// item is invalidated automatically if the device's enrolled biometrics change (a new
    /// face/fingerprint added or all removed). This is distinct from the plain `save(_:forKey:)`
    /// above, which protects by device passcode only.
    func saveBiometricProtected(_ value: String, forKey key: String) -> Bool {
        if isRunningTests { return true }
        guard let data = value.data(using: .utf8) else { return false }

        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: access
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Reads a value saved via `saveBiometricProtected`. The system presents the Face ID/Touch ID
    /// prompt itself as part of `SecItemCopyMatching` — there's no separate `LAContext.evaluatePolicy`
    /// call needed (or wanted; a second prompt would be redundant). `prompt` is the reason string
    /// shown in that system UI. Returns nil on cancel, failure, or if nothing was ever saved.
    func retrieveBiometricProtected(forKey key: String, prompt: String) -> String? {
        if isRunningTests { return nil }

        let context = LAContext()
        context.localizedReason = prompt

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Whether a biometric-protected item exists for `key`, without triggering the Face ID
    /// prompt — used to decide whether to show the "Log in with Face ID" affordance at all.
    /// Queries existence only (`kSecReturnData: false`), so it never asks for biometrics itself;
    /// a stale item left behind after biometry enrollment changed still reports true here
    /// (iOS only invalidates it at actual read time), so the real read can still fail/cancel.
    func hasBiometricProtectedValue(forKey key: String) -> Bool {
        if isRunningTests { return false }

        let context = LAContext()
        context.interactionNotAllowed = true

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecUseAuthenticationContext as String: context
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        // errSecInteractionNotAllowed means the item exists but needs biometric auth to read —
        // exactly the "yes it's there" signal we want without prompting.
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }
}
