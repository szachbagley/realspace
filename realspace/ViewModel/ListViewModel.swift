//
//  ListViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class ListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedAction: String = "watch"
    @Published var itemSubject: String = ""
    @Published var isPublic: Bool = false
    @Published var listItems: [ListItemResponse] = []
    @Published var isLoading = false
    @Published var isCreatingItem = false
    @Published var errorMessage: String?

    // MARK: - Constants
    let actions = ["watch", "read", "go to"]

    // MARK: - Services
    private let apiService = APIService.shared

    init() {}

    // MARK: - Data Loading

    func loadListItems() async {
        isLoading = true
        errorMessage = nil

        do {
            listItems = try await apiService.getListItems()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Error loading list: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to load list"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - List Item Creation

    func createListItem() async {
        guard canCreateItem else { return }

        isCreatingItem = true
        errorMessage = nil

        do {
            let newItem = try await apiService.createListItem(
                action: selectedAction,
                subject: itemSubject,
                isPublic: isPublic
            )

            // Add new item to the beginning of the list
            listItems.insert(newItem, at: 0)

            clearForm()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to create list item: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to create list item"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isCreatingItem = false
    }

    func deleteListItem(_ item: ListItemResponse) async {
        do {
            try await apiService.deleteListItem(id: item.id)

            // Remove from local array
            listItems.removeAll { $0.id == item.id }
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to delete item: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            default:
                errorMessage = "Failed to delete item"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    func clearForm() {
        itemSubject = ""
        selectedAction = "watch"
        isPublic = false
    }

    // MARK: - Validation

    var canCreateItem: Bool {
        !itemSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
