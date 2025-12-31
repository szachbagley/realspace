//
//  TopicFeedViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class TopicFeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var postContent: String = ""
    @Published var posts: [TopicPostResponse] = []
    @Published var isLoading = false
    @Published var isCreatingPost = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let apiService = APIService.shared

    // MARK: - Topic
    var topicID: String?

    init() {}

    // MARK: - Data Loading

    func loadPosts(topicID: String) async {
        self.topicID = topicID
        isLoading = true
        errorMessage = nil

        do {
            posts = try await apiService.getTopicPosts(topicID: topicID)
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
        guard canPost, let topicID = topicID else { return }

        isCreatingPost = true
        errorMessage = nil

        do {
            let newPost = try await apiService.createTopicPost(
                topicID: topicID,
                content: postContent
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
        postContent = ""
    }

    // MARK: - Post Actions

    func likePost(_ post: TopicPostResponse) async {
        do {
            let updatedPost: TopicPostResponse

            if post.isLikedByCurrentUser == true {
                // Unlike the post
                updatedPost = try await apiService.unlikeTopicPost(id: post.id)
            } else {
                // Like the post
                updatedPost = try await apiService.likeTopicPost(id: post.id)
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

    func deletePost(_ post: TopicPostResponse) async {
        do {
            try await apiService.deleteTopicPost(id: post.id)

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
        !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
