//
//  TopicFeedView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct TopicFeedView: View {
    let topicID: String
    let topicName: String
    @StateObject private var viewModel = TopicFeedViewModel()
    @EnvironmentObject var authManager: AuthManager

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
                Text(topicName)
                    .font(.postAuthor)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            // Post entry field
            VStack(alignment: .leading, spacing: 10) {
                TextField("Share your thoughts...", text: $viewModel.postContent, axis: .vertical)
                    .font(.postBody)
                    .lineLimit(3...10)
                    .textFieldStyle(PlainTextFieldStyle())

                // Post button
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await viewModel.createPost()
                        }
                    } label: {
                        if viewModel.isCreatingPost {
                            ProgressView()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        } else {
                            Text("Post")
                                .font(.postBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(.black))
                        }
                    }
                    .disabled(viewModel.isCreatingPost || !viewModel.canPost)
                    .opacity(viewModel.canPost && !viewModel.isCreatingPost ? 1.0 : 0.5)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .border(.black, width: 0.5)
            .padding(.horizontal)
            .padding(.top, 15)

            // Topic posts feed
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.posts, id: \.id) { post in
                            VStack(alignment: .leading, spacing: 10) {
                                // Post header
                                HStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 35, height: 35)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(post.author.displayName)
                                            .font(.postAuthor)
                                            .fontWeight(.bold)

                                        Text("@\(post.author.username)")
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
                                    Button {
                                        Task {
                                            await viewModel.likePost(post)
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: post.isLikedByCurrentUser == true ? "heart.fill" : "heart")
                                            Text("\(post.likesCount)")
                                        }
                                        .font(.caption)
                                        .foregroundColor(post.isLikedByCurrentUser == true ? .red : .secondary)
                                    }

                                    Label("\(post.commentsCount ?? 0)", systemImage: "bubble.right")
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
            }
            .refreshable {
                await viewModel.loadPosts(topicID: topicID)
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
        .task {
            await viewModel.loadPosts(topicID: topicID)
        }
    }
}
