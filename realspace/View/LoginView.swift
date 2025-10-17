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
                }

                // Login button
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Login")
                        .font(.postBody)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(.black))
                        .foregroundColor(.white)
                        .border(.black, width: 0.5)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            MainTabView()
        }
    }
}

#Preview {
    LoginView()
}
