//
//  ListViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class ListViewModel {
    var selectedAction: String = "watch"
    var itemSubject: String = ""

    let actions = ["watch", "read", "go to"]

    private var modelContext: ModelContext?

    init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - List Item Creation

    func createListItem(user: User) {
        guard !itemSubject.isEmpty else { return }

        let listItem = ListItem(
            action: selectedAction,
            subject: itemSubject,
            user: user
        )

        modelContext?.insert(listItem)

        do {
            try modelContext?.save()
            clearForm()
        } catch {
            print("Error saving list item: \(error)")
        }
    }

    func clearForm() {
        itemSubject = ""
        selectedAction = "watch"
    }

    // MARK: - Validation

    var canCreateItem: Bool {
        !itemSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
