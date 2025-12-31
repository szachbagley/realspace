//
//  MainTabView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: String = "Friends"
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ZStack {
                    // Display the appropriate view based on selected tab
                    Group {
                        switch selectedTab {
                        case "Friends":
                            FriendsView(selectedTab: $selectedTab)
                                .environmentObject(authManager)
                        case "Community":
                            CommunityView(selectedTab: $selectedTab)
                                .environmentObject(authManager)
                        case "Topics":
                            TopicsView(selectedTab: $selectedTab)
                                .environmentObject(authManager)
                        case "List":
                            ListView(selectedTab: $selectedTab)
                                .environmentObject(authManager)
                        default:
                            FriendsView(selectedTab: $selectedTab)
                                .environmentObject(authManager)
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
