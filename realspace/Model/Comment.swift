//
//  Comment.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class Comment {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdAt: Date

    // Relationships
    var author: User?
    var post: Post?
    var topicPost: TopicPost?

    init(content: String, author: User, post: Post? = nil, topicPost: TopicPost? = nil) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.author = author
        self.post = post
        self.topicPost = topicPost
    }
}
