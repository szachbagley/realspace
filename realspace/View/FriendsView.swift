//
//  FriendsView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct FriendsView: View {
    @Binding var selectedTab: String
    @StateObject private var viewModel = FriendsViewModel()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 0) {
            // Top banner
            HStack {
                Text("Realspace")
                    .font(.appTitle)
                    .fontWeight(.bold)

                Spacer()

                // Logout button
                Menu {
                    if let user = authManager.currentUser {
                        Text("@\(user.username)")
                            .font(.postBody)

                        Divider()
                    }

                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        )
                }
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

            // Post entry field
            VStack(alignment: .leading, spacing: 10) {
                // Post title: Action + Subject
                HStack(spacing: 5) {
                    Text("I")
                        .font(.postBody)

                    Menu {
                        ForEach(viewModel.actions, id: \.self) { action in
                            Button(action) {
                                viewModel.selectedAction = action
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(viewModel.selectedAction)
                                .font(.postBody)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.black))
                    }

                    TextField("subject", text: $viewModel.postSubject)
                        .font(.postBody)
                        .textFieldStyle(PlainTextFieldStyle())
                }

                // Post body
                TextField("Share your thoughts...", text: $viewModel.postBody, axis: .vertical)
                    .font(.postBody)
                    .lineLimit(3...10)
                    .textFieldStyle(PlainTextFieldStyle())

                // Image attachment button
                HStack(spacing: 12) {
                    Button {
                        // Image picker would go here
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.caption)
                            Text("Add Photo")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }

                    Spacer()
                }

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

            // Posts feed
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
                                            .fontWeight(.bold) +
                                        Text(" \(post.action) ") +
                                        Text(post.subject)
                                            .fontWeight(.bold)
                                            .font(.postAuthor)

                                        Text("@\(post.author.username)")
                                            .font(.postBody)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }

                                // Post content
                                if let content = post.content, !content.isEmpty {
                                    Text(content)
                                        .font(.postBody)
                                }

                                // Image placeholder (if imageURL exists)
                                if let imageURL = post.imageURL, !imageURL.isEmpty {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 200)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo")
                                                    .font(.title)
                                                    .foregroundColor(.gray)
                                                Text("Image Preview")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }

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
                await viewModel.loadPosts()
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
            await viewModel.loadPosts()
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = "Friends"

    FriendsView(selectedTab: $selectedTab)
        .environmentObject(AuthManager.shared)
}
