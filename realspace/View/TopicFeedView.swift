//
//  TopicFeedView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

struct TopicFeedView: View {
    let topic: Topic
    @State private var viewModel = TopicFeedViewModel()
    @State private var postContent: String = ""
    @Query(sort: \User.createdAt) private var users: [User]
    @Environment(\.modelContext) private var modelContext

    var topicPosts: [TopicPost] {
        topic.posts?.sorted(by: { $0.createdAt > $1.createdAt }) ?? []
    }

    var body: some View {
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

            // Topic header
            VStack(alignment: .leading, spacing: 5) {
                Text(topic.name)
                    .font(.postAuthor)
                    .fontWeight(.bold)

                Text(topic.topicDescription)
                    .font(.postBody)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Post entry field
            VStack(alignment: .leading, spacing: 10) {
                TextField("Share your thoughts...", text: $postContent, axis: .vertical)
                    .font(.postBody)
                    .lineLimit(3...10)
                    .textFieldStyle(PlainTextFieldStyle())

                // Post button
                HStack {
                    Spacer()
                    Button(action: createPost) {
                        Text("Post")
                            .font(.postBody)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(.black))
                    }
                    .disabled(!canPost)
                    .opacity(canPost ? 1.0 : 0.5)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .border(.black, width: 0.5)
            .padding(.horizontal)
            .padding(.top, 15)

            // Topic posts feed
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(topicPosts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            // Post header
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 35, height: 35)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(post.author?.displayName ?? "Unknown")
                                        .font(.postAuthor)
                                        .fontWeight(.bold)

                                    Text("@\(post.author?.username ?? "unknown")")
                                        .font(.postBody)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }

                            // Post content
                            Text(post.content)
                                .font(.postBody)

                            // Post metadata
                            HStack(spacing: 15) {
                                Label("\(post.likesCount)", systemImage: "heart")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Label("\(post.comments?.count ?? 0)", systemImage: "bubble.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .border(.black, width: 0.5)
                    }
                }
                .padding()
            }

            // Bottom navbar with tabs
            HStack(spacing: 20) {
                ForEach(["Friends", "Community", "Topics", "List"], id: \.self) { tab in
                    Button(action: {
                        // Tab navigation will be handled later
                    }) {
                        Text(tab)
                            .font(.postBody)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(tab == "Topics" ? Color.white : Color.clear)
                            .foregroundColor(tab == "Topics" ? .black : .white)
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

    // MARK: - Helper Functions

    private var canPost: Bool {
        !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func getCurrentUser() -> User {
        // Try to get an existing user, or create a sample user
        if let existingUser = users.first {
            return existingUser
        } else {
            let newUser = User(username: "sampleuser", displayName: "Sample User")
            modelContext.insert(newUser)
            try? modelContext.save()
            return newUser
        }
    }

    private func createPost() {
        guard canPost else { return }

        let author = getCurrentUser()

        let topicPost = TopicPost(
            content: postContent,
            author: author,
            topic: topic
        )

        modelContext.insert(topicPost)

        do {
            try modelContext.save()
            clearForm()
        } catch {
            print("Error saving topic post: \(error)")
        }
    }

    private func clearForm() {
        postContent = ""
    }
}
