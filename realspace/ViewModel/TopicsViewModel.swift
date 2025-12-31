//
//  TopicsViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class TopicsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var topics: [TopicResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let apiService = APIService.shared

    init() {}

    // MARK: - Data Loading

    func loadTopics() async {
        isLoading = true
        errorMessage = nil

        do {
            topics = try await apiService.getTopics()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Error loading topics: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to load topics"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Search

    var filteredTopics: [TopicResponse] {
        if searchText.isEmpty {
            return topics
        } else {
            return topics.filter { topic in
                topic.name.localizedCaseInsensitiveContains(searchText) ||
                topic.topicDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
