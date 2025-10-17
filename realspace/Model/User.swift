//
//  User.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID
    var username: String
    var displayName: String
    var bio: String
    var profileImageURL: String?
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Post.author)
    var posts: [Post]?
    
    @Relationship(deleteRule: .cascade)
    var likedPosts: [Post]?
    
    init(username: String, displayName: String, bio: String = "", profileImageURL: String? = nil) {
        self.id = UUID()
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.createdAt = Date()
        self.posts = []
        self.likedPosts = []
    }
}
