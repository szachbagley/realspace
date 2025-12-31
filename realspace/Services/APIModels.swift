import Foundation

// MARK: - Base Response
struct APIError: Codable, Error {
    let error: Bool
    let reason: String
}

// MARK: - Auth DTOs
struct RegisterRequest: Codable {
    let username: String
    let displayName: String
    let email: String
    let password: String
    let bio: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let username: String
    let displayName: String
    let bio: String
    let profileImageURL: String?
    let createdAt: Date?
}

struct UserSummary: Codable {
    let id: String
    let username: String
    let displayName: String
}

// MARK: - Post DTOs
struct CreatePostRequest: Codable {
    let action: String
    let subject: String
    let content: String?
    let imageURL: String?
}

struct UpdatePostRequest: Codable {
    let content: String?
    let imageURL: String?
}

struct PostResponse: Codable {
    let id: String
    let action: String
    let subject: String
    let content: String?
    let imageURL: String?
    let likesCount: Int
    let createdAt: Date?
    let author: UserSummary
    let isLikedByCurrentUser: Bool?
    let commentsCount: Int?
}

// MARK: - Topic DTOs
struct CreateTopicRequest: Codable {
    let name: String
    let topicDescription: String
}

struct TopicResponse: Codable {
    let id: String
    let name: String
    let topicDescription: String
    let createdAt: Date?
    let postsCount: Int?
}

struct TopicSummary: Codable {
    let id: String
    let name: String
    let topicDescription: String
}

// MARK: - Topic Post DTOs
struct CreateTopicPostRequest: Codable {
    let content: String
}

struct UpdateTopicPostRequest: Codable {
    let content: String
}

struct TopicPostResponse: Codable {
    let id: String
    let content: String
    let likesCount: Int
    let createdAt: Date?
    let author: UserSummary
    let topic: TopicSummary
    let isLikedByCurrentUser: Bool?
    let commentsCount: Int?
}

// MARK: - Comment DTOs
struct CreateCommentRequest: Codable {
    let content: String
}

struct CommentResponse: Codable {
    let id: String
    let content: String
    let createdAt: Date?
    let author: UserSummary
}

// MARK: - Entity DTOs
struct CreateEntityRequest: Codable {
    let name: String
    let address: String
    let imageURL: String?
}

struct UpdateEntityRequest: Codable {
    let name: String?
    let address: String?
    let imageURL: String?
}

struct EntityResponse: Codable {
    let id: String
    let name: String
    let address: String
    let imageURL: String?
    let createdAt: Date?
    let eventsCount: Int?
}

struct EntitySummary: Codable {
    let id: String
    let name: String
    let address: String
}

// MARK: - Event DTOs
struct CreateEventRequest: Codable {
    let name: String
    let date: Date
    let entityID: String
    let eventDescription: String?
    let link: String?
    let imageURL: String?
}

struct UpdateEventRequest: Codable {
    let name: String?
    let date: Date?
    let eventDescription: String?
    let link: String?
    let imageURL: String?
}

struct EventResponse: Codable {
    let id: String
    let name: String
    let date: Date
    let eventDescription: String?
    let link: String?
    let imageURL: String?
    let createdAt: Date?
    let entity: EntitySummary
}

// MARK: - List Item DTOs
struct CreateListItemRequest: Codable {
    let action: String
    let subject: String
    let isPublic: Bool
}

struct ListItemResponse: Codable {
    let id: String
    let action: String
    let subject: String
    let isPublic: Bool
    let createdAt: Date?
}
