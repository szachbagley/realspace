//
//  PreviewHelper.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import Foundation
import SwiftData

extension ModelContainer {
    static var preview: ModelContainer {
        preview(with: .standard)
    }
    
    static func preview(with scenario: PreviewScenario) -> ModelContainer {
        let container = try! ModelContainer(
            for: User.self, Post.self, Comment.self, Entity.self, Event.self, Topic.self, TopicPost.self, ListItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let context = container.mainContext

        switch scenario {
        case .standard:
            addStandardData(to: context)
        case .emptyFeed:
            addEmptyFeedData(to: context)
        case .manyPosts:
            addManyPosts(to: context)
        }

        return container
    }
    
    private static func addStandardData(to context: ModelContext) {
        let alice = User(username: "alice", displayName: "Alice Johnson")
        let bob = User(username: "bob", displayName: "Bob Smith")

        context.insert(alice)
        context.insert(bob)

        let post1 = Post(action: "watched", subject: "The Godfather", content: "One of the best films I've ever seen. The cinematography was stunning and the performances were incredible.", author: alice)
        let post2 = Post(action: "read", subject: "The Autobiography of Malcolm X", content: "A powerful and eye-opening read. Malcolm X's journey is both inspiring and thought-provoking.", author: bob)
        context.insert(post1)
        context.insert(post2)

        // Entities
        let coffeeShop = Entity(name: "Blue Bottle Coffee", address: "123 Main St, San Francisco, CA")
        let library = Entity(name: "Central Library", address: "456 Library Ave, San Francisco, CA")
        let theater = Entity(name: "The Roxie Theater", address: "789 Valencia St, San Francisco, CA")

        context.insert(coffeeShop)
        context.insert(library)
        context.insert(theater)

        // Events
        let event1 = Event(
            name: "Open Mic Night",
            date: Date().addingTimeInterval(86400 * 3),
            entity: coffeeShop,
            eventDescription: "Join us for an evening of poetry and music. All skill levels welcome!",
            link: "https://bluebottle.com/events"
        )

        let event2 = Event(
            name: "Book Club: Modern Fiction",
            date: Date().addingTimeInterval(86400 * 7),
            entity: library,
            eventDescription: "This month we're discussing contemporary fiction. New members welcome."
        )

        let event3 = Event(
            name: "Classic Film Series: Hitchcock",
            date: Date().addingTimeInterval(86400 * 5),
            entity: theater,
            eventDescription: "Screening Rear Window followed by a discussion with film scholars."
        )

        context.insert(event1)
        context.insert(event2)
        context.insert(event3)

        // Topics
        let topic1 = Topic(
            name: "Film & Cinema",
            topicDescription: "Discussion of classic and contemporary films, directors, and cinematic techniques"
        )

        let topic2 = Topic(
            name: "Literature",
            topicDescription: "Books, poetry, and written works from all genres and time periods"
        )

        let topic3 = Topic(
            name: "Star Wars",
            topicDescription: "Discussion of the Star Wars universe, films, shows, and expanded media"
        )

        let topic4 = Topic(
            name: "Coffee Culture",
            topicDescription: "Everything about coffee, from brewing techniques to cafe recommendations"
        )

        context.insert(topic1)
        context.insert(topic2)
        context.insert(topic3)
        context.insert(topic4)

        // Topic Posts
        let topicPost1 = TopicPost(
            content: "I just rewatched The Empire Strikes Back and I'm still amazed at how well the practical effects hold up. The Hoth battle sequence is incredible.",
            author: alice,
            topic: topic3
        )

        let topicPost2 = TopicPost(
            content: "Hot take: The Phantom Menace gets too much hate. The podracing sequence alone makes it worth watching.",
            author: bob,
            topic: topic3
        )

        let topicPost3 = TopicPost(
            content: "Finally saw the Criterion Collection release of Seven Samurai. Kurosawa's influence on modern cinema is undeniable.",
            author: alice,
            topic: topic1
        )

        let topicPost4 = TopicPost(
            content: "Anyone else think Andor is the best Star Wars content in years? The writing is phenomenal.",
            author: bob,
            topic: topic3
        )

        context.insert(topicPost1)
        context.insert(topicPost2)
        context.insert(topicPost3)
        context.insert(topicPost4)

        // List Items
        let listItem1 = ListItem(action: "watch", subject: "Dune: Part Two", user: alice)
        let listItem2 = ListItem(action: "read", subject: "Project Hail Mary", user: alice)
        let listItem3 = ListItem(action: "go to", subject: "MoMA", user: alice)
        let listItem4 = ListItem(action: "watch", subject: "The Last of Us Season 2", user: alice)

        context.insert(listItem1)
        context.insert(listItem2)
        context.insert(listItem3)
        context.insert(listItem4)
    }

    private static func addEmptyFeedData(to context: ModelContext) {
        let user = User(username: "newuser", displayName: "New User")
        context.insert(user)
    }

    private static func addManyPosts(to context: ModelContext) {
        let user = User(username: "prolific", displayName: "Prolific Poster")
        context.insert(user)

        let actions = ["watched", "read", "went to"]
        let subjects = ["Inception", "1984", "The Louvre", "Blade Runner 2049", "Sapiens", "Central Park"]

        for i in 1...20 {
            let action = actions[i % actions.count]
            let subject = subjects[i % subjects.count]
            let post = Post(action: action, subject: subject, content: "This was experience number \(i). Really enjoyed it!", author: user)
            context.insert(post)
        }
    }
}

enum PreviewScenario {
    case standard
    case emptyFeed
    case manyPosts
}
