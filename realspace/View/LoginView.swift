//
//  LoginView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)

            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Enter your email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }

            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                SecureField("Enter your password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // Error message
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // Login button
            Button(action: {
                viewModel.login()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)
            .padding(.top, 10)

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 50)
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    LoginView()
}
