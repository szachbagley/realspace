//
//  LoginViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false

    func login() {
        // Simple redirect to Home view
        isLoggedIn = true
    }
}
