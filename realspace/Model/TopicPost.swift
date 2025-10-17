//
//  TopicPost.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class TopicPost {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdAt: Date
    var likesCount: Int

    // Relationships
    var author: User?
    var topic: Topic?

    @Relationship(deleteRule: .cascade, inverse: \Comment.topicPost)
    var comments: [Comment]?

    init(content: String, author: User, topic: Topic) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.likesCount = 0
        self.author = author
        self.topic = topic
        self.comments = []
    }
}
