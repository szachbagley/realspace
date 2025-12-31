//
//  LoginView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 0) {
            // Top banner
            HStack {
                Text("Realspace")
                    .font(.appTitle)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)

            Spacer()

            // Login form
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.postAuthor)
                    .fontWeight(.bold)

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.postBody)

                    TextField("Enter your email", text: $viewModel.email)
                        .font(.postBody)
                        .padding()
                        .background(Color(.systemBackground))
                        .border(.black, width: 0.5)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .disabled(viewModel.isLoading)
                }

                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.postBody)

                    SecureField("Enter your password", text: $viewModel.password)
                        .font(.postBody)
                        .padding()
                        .background(Color(.systemBackground))
                        .border(.black, width: 0.5)
                        .disabled(viewModel.isLoading)
                }

                // Login button
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    } else {
                        Text("Login")
                            .font(.postBody)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(.black))
                            .foregroundColor(.white)
                            .border(.black, width: 0.5)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.top, 10)

                // Register link
                Button {
                    showRegister = true
                } label: {
                    Text("Don't have an account? Register")
                        .font(.postBody)
                        .foregroundColor(.black)
                }
                .padding(.top, 20)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            MainTabView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

#Preview {
    LoginView()
}
