//
//  realspaceApp.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

@main
struct realspaceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Post.self,
            Comment.self,
            Entity.self,
            Event.self,
            Topic.self,
            TopicPost.self,
            ListItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(sharedModelContainer)
    }
}
