//
//  FriendsViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedAction: String = "watched"
    @Published var postSubject: String = ""
    @Published var postBody: String = ""
    @Published var selectedTab: String = "Friends"

    @Published var posts: [PostResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCreatingPost = false

    // MARK: - Constants
    let actions = ["watched", "read", "went to"]

    // MARK: - Services
    private let apiService = APIService.shared

    init() {}

    // MARK: - Data Loading

    func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            posts = try await apiService.getPosts()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Error loading posts: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to load posts"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Post Creation

    func createPost() async {
        guard canPost else { return }

        isCreatingPost = true
        errorMessage = nil

        let content = postBody.isEmpty ? nil : postBody

        do {
            let newPost = try await apiService.createPost(
                action: selectedAction,
                subject: postSubject,
                content: content
            )

            // Add new post to the beginning of the list
            posts.insert(newPost, at: 0)

            clearPostForm()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to create post: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to create post"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isCreatingPost = false
    }

    func clearPostForm() {
        postSubject = ""
        postBody = ""
        selectedAction = "watched"
    }

    // MARK: - Post Actions

    func likePost(_ post: PostResponse) async {
        do {
            let updatedPost: PostResponse

            if post.isLikedByCurrentUser == true {
                // Unlike the post
                updatedPost = try await apiService.unlikePost(id: post.id)
            } else {
                // Like the post
                updatedPost = try await apiService.likePost(id: post.id)
            }

            // Update the post in the array
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index] = updatedPost
            }
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to like post: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            default:
                errorMessage = "Failed to like post"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    func deletePost(_ post: PostResponse) async {
        do {
            try await apiService.deletePost(id: post.id)

            // Remove from local array
            posts.removeAll { $0.id == post.id }
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to delete post: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            default:
                errorMessage = "Failed to delete post"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    // MARK: - Validation

    var canPost: Bool {
        !postSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Tab Selection

    func selectTab(_ tab: String) {
        selectedTab = tab
    }
}
