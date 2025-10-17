//
//  TopicsViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class TopicsViewModel {
    var searchText: String = ""

    private var modelContext: ModelContext?

    init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Search

    var filteredTopics: [Topic] {
        // Will be implemented when search functionality is added
        return []
    }
}
