//
//  MainTabView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: String = "Friends"

    var body: some View {
        ZStack {
            // Display the appropriate view based on selected tab
            Group {
                switch selectedTab {
                case "Friends":
                    FriendsView(selectedTab: $selectedTab)
                case "Community":
                    CommunityView(selectedTab: $selectedTab)
                case "Topics":
                    TopicsView(selectedTab: $selectedTab)
                case "List":
                    ListView(selectedTab: $selectedTab)
                default:
                    FriendsView(selectedTab: $selectedTab)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(.preview)
}
