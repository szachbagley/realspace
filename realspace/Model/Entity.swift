//
//  Entity.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

@Model
class Entity {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageURL: String?
    var address: String
    var createdAt: Date

    init(name: String, imageURL: String? = nil, address: String) {
        self.id = UUID()
        self.name = name
        self.imageURL = imageURL
        self.address = address
        self.createdAt = Date()
    }
}
