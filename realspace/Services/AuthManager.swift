import Foundation
import Security
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: UserResponse?

    private let tokenKey = "jwt_token"
    private let keychainService = "com.realspace.app"

    private init() {
        // Check if we have a stored token on init
        if getToken() != nil {
            isAuthenticated = true
        }
    }

    // MARK: - Token Management

    func saveToken(_ token: String) {
        // Save to Keychain
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        // Delete any existing token first
        SecItemDelete(query as CFDictionary)

        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            isAuthenticated = true
        }
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]

        SecItemDelete(query as CFDictionary)
        isAuthenticated = false
        currentUser = nil
    }

    // MARK: - Auth Actions

    func login(token: String, user: UserResponse) {
        saveToken(token)
        currentUser = user
    }

    func logout() {
        deleteToken()
    }
}
