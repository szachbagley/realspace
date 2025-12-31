//
//  LoginViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var displayName: String = ""
    @Published var bio: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false

    // MARK: - Services
    private let apiService = APIService.shared
    private let authManager = AuthManager.shared

    // MARK: - Authentication

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            authManager.login(token: response.token, user: response.user)
            isLoggedIn = true
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = message
            case .unauthorized:
                errorMessage = "Invalid credentials"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "An error occurred"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func register() async {
        guard !username.isEmpty, !displayName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.register(
                username: username,
                displayName: displayName,
                email: email,
                password: password,
                bio: bio.isEmpty ? nil : bio
            )
            authManager.login(token: response.token, user: response.user)
            isLoggedIn = true
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = message
            case .unauthorized:
                errorMessage = "Registration failed"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "An error occurred"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func logout() {
        authManager.logout()
        isLoggedIn = false
        clearFields()
    }

    func clearFields() {
        email = ""
        password = ""
        username = ""
        displayName = ""
        bio = ""
        errorMessage = nil
    }
}
