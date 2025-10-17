//
//  Topic.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class Topic {
    @Attribute(.unique) var id: UUID
    var name: String
    var topicDescription: String
    var createdAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \TopicPost.topic)
    var posts: [TopicPost]?

    init(name: String, topicDescription: String) {
        self.id = UUID()
        self.name = name
        self.topicDescription = topicDescription
        self.createdAt = Date()
        self.posts = []
    }
}
