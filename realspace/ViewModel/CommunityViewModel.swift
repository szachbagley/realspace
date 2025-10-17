//
//  CommunityViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class CommunityViewModel {
    var eventName: String = ""
    var eventDate: Date = Date()
    var eventDescription: String = ""
    var selectedEntity: Entity?

    private var modelContext: ModelContext?

    init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Event Creation

    func createEvent() {
        guard !eventName.isEmpty, let entity = selectedEntity else { return }

        let description = eventDescription.isEmpty ? nil : eventDescription
        let event = Event(
            name: eventName,
            date: eventDate,
            entity: entity,
            eventDescription: description
        )

        modelContext?.insert(event)

        do {
            try modelContext?.save()
            clearEventForm()
        } catch {
            print("Error saving event: \(error)")
        }
    }

    func clearEventForm() {
        eventName = ""
        eventDate = Date()
        eventDescription = ""
        selectedEntity = nil
    }

    // MARK: - Validation

    var canCreateEvent: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedEntity != nil
    }
}
