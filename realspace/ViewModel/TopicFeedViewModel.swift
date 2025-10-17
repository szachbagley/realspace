//
//  TopicFeedViewModel.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class TopicFeedViewModel {
    var postContent: String = ""

    private var modelContext: ModelContext?

    init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Post Creation

    func createPost(author: User, topic: Topic) {
        guard !postContent.isEmpty else { return }

        let post = TopicPost(
            content: postContent,
            author: author,
            topic: topic
        )

        modelContext?.insert(post)

        do {
            try modelContext?.save()
            clearPostForm()
        } catch {
            print("Error saving topic post: \(error)")
        }
    }

    func clearPostForm() {
        postContent = ""
    }

    // MARK: - Validation

    var canPost: Bool {
        !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
