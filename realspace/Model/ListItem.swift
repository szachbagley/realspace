//
//  ListItem.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class ListItem {
    @Attribute(.unique) var id: UUID
    var action: String
    var subject: String
    var isPublic: Bool
    var createdAt: Date

    // Relationships
    var user: User?

    init(action: String, subject: String, isPublic: Bool = false, user: User) {
        self.id = UUID()
        self.action = action
        self.subject = subject
        self.isPublic = isPublic
        self.createdAt = Date()
        self.user = user
    }
}
