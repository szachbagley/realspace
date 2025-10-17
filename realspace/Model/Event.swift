//
//  Event.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class Event {
    @Attribute(.unique) var id: UUID
    var name: String
    var date: Date
    var imageURL: String?
    var eventDescription: String?
    var link: String?
    var createdAt: Date

    // Relationships
    var entity: Entity?

    init(name: String, date: Date, entity: Entity, imageURL: String? = nil, eventDescription: String? = nil, link: String? = nil) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.entity = entity
        self.imageURL = imageURL
        self.eventDescription = eventDescription
        self.link = link
        self.createdAt = Date()
    }
}
