//
//  LoginViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false

    func login() {
        // Reset error message
        errorMessage = ""

        // Validate input
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        // Simulate login process
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false

            // Simulate successful login (in a real app, you'd call an API here)
            if self?.email == "demo@example.com" && self?.password == "password" {
                self?.isLoggedIn = true
            } else {
                self?.errorMessage = "Invalid email or password"
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
