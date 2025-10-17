//
//  TopicsView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

struct TopicsView: View {
    @Binding var selectedTab: String
    @State private var viewModel = TopicsViewModel()
    @Query(sort: \Topic.name) private var topics: [Topic]
    @Environment(\.modelContext) private var modelContext

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

            // Search bar
            TextField("Search topics...", text: $viewModel.searchText)
                .font(.postBody)
                .padding()
                .background(Color(.systemBackground))
                .border(.black, width: 0.5)
                .padding(.horizontal)
                .padding(.top, 15)

            // Followed Topics section
            VStack(alignment: .leading, spacing: 10) {
                Text("Followed Topics")
                    .font(.postAuthor)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 20)

                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(topics) { topic in
                            NavigationLink(destination: TopicFeedView(topic: topic)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(topic.name)
                                        .font(.postAuthor)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)

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
        .onAppear {
            viewModel.configure(with: modelContext)
        }
        }
    }
}

// Preview wrapper to provide binding
private struct TopicsViewPreview: View {
    @State private var selectedTab = "Topics"

    var body: some View {
        TopicsView(selectedTab: $selectedTab)
    }
}

#Preview {
    TopicsViewPreview()
        .modelContainer(.preview)
}
