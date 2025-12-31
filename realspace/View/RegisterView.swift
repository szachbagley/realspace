//
//  RegisterView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top banner
                HStack {
                    Text("Realspace")
                        .font(.appTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)

                ScrollView {
                    // Registration form
                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.postAuthor)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.postBody)

                            TextField("Choose a username", text: $viewModel.username)
                                .font(.postBody)
                                .padding()
                                .background(Color(.systemBackground))
                                .border(.black, width: 0.5)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .disabled(viewModel.isLoading)
                        }

                        // Display Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.postBody)

                            TextField("Your display name", text: $viewModel.displayName)
                                .font(.postBody)
                                .padding()
                                .background(Color(.systemBackground))
                                .border(.black, width: 0.5)
                                .disabled(viewModel.isLoading)
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

                            SecureField("Choose a password", text: $viewModel.password)
                                .font(.postBody)
                                .padding()
                                .background(Color(.systemBackground))
                                .border(.black, width: 0.5)
                                .disabled(viewModel.isLoading)
                        }

                        // Bio field (optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (Optional)")
                                .font(.postBody)

                            TextField("Tell us about yourself", text: $viewModel.bio, axis: .vertical)
                                .font(.postBody)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(.systemBackground))
                                .border(.black, width: 0.5)
                                .disabled(viewModel.isLoading)
                        }

                        // Register button
                        Button {
                            Task {
                                await viewModel.register()
                                if viewModel.isLoggedIn {
                                    dismiss()
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                            } else {
                                Text("Create Account")
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

                        // Back to login
                        Button {
                            dismiss()
                        } label: {
                            Text("Already have an account? Login")
                                .font(.postBody)
                                .foregroundColor(.black)
                        }
                        .padding(.top, 20)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
                MainTabView()
            }
        }
    }
}

#Preview {
    RegisterView()
}
