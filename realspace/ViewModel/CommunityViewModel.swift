//
//  CommunityViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    // MARK: - Published Properties

    // Event creation form
    @Published var eventName: String = ""
    @Published var eventDate: Date = Date()
    @Published var eventDescription: String = ""
    @Published var selectedEntityID: String?

    // Data
    @Published var events: [EventResponse] = []
    @Published var entities: [EntityResponse] = []

    // State
    @Published var isLoading = false
    @Published var isCreatingEvent = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let apiService = APIService.shared

    init() {}

    // MARK: - Data Loading

    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            events = try await apiService.getEvents()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Error loading events: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to load events"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadEntities() async {
        errorMessage = nil

        do {
            entities = try await apiService.getEntities()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Error loading entities: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to load entities"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    // MARK: - Event Creation

    func createEvent() async {
        guard canCreateEvent else { return }

        isCreatingEvent = true
        errorMessage = nil

        let description = eventDescription.isEmpty ? nil : eventDescription

        do {
            let newEvent = try await apiService.createEvent(
                name: eventName,
                date: eventDate,
                entityID: selectedEntityID!,
                description: description,
                link: nil,
                imageURL: nil
            )

            // Add new event to the beginning of the list
            events.insert(newEvent, at: 0)

            clearEventForm()
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = "Failed to create event: \(message)"
            case .unauthorized:
                errorMessage = "Please log in again"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "Failed to create event"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isCreatingEvent = false
    }

    func clearEventForm() {
        eventName = ""
        eventDate = Date()
        eventDescription = ""
        selectedEntityID = nil
    }

    // MARK: - Validation

    var canCreateEvent: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedEntityID != nil
    }
}
