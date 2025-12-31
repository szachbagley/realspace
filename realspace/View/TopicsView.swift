//
//  TopicsView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct TopicsView: View {
    @Binding var selectedTab: String
    @StateObject private var viewModel = TopicsViewModel()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
        VStack(spacing: 0) {
            // Top banner
            HStack {
                Text("Realspace")
                    .font(.appTitle)
                    .fontWeight(.bold)

                Spacer()

                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)

            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            // Search bar
            TextField("Search topics...", text: $viewModel.searchText)
                .font(.postBody)
                .padding()
                .background(Color(.systemBackground))
                .border(.black, width: 0.5)
                .padding(.horizontal)
                .padding(.top, 15)

            // Topics section
            VStack(alignment: .leading, spacing: 10) {
                Text("Topics")
                    .font(.postAuthor)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 20)

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.filteredTopics, id: \.id) { topic in
                                NavigationLink(destination: TopicFeedView(topicID: topic.id, topicName: topic.name)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(topic.name)
                                                .font(.postAuthor)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)

                                            Spacer()

                                            if let postsCount = topic.postsCount {
                                                Text("\(postsCount) posts")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }

                                        Text(topic.topicDescription)
                                            .font(.postBody)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .border(.black, width: 0.5)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .refreshable {
                    await viewModel.loadTopics()
                }
            }

            // Bottom navbar with tabs
            HStack(spacing: 20) {
                ForEach(["Friends", "Community", "Topics", "List"], id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.postBody)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.white : Color.clear)
                            .foregroundColor(selectedTab == tab ? .black : .white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.black))
            .edgesIgnoringSafeArea(.horizontal)
        }
        .task {
            await viewModel.loadTopics()
        }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = "Topics"

    TopicsView(selectedTab: $selectedTab)
        .environmentObject(AuthManager.shared)
}
