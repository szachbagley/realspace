import Foundation

enum APIServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int, String)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unauthorized
}

class APIService {
    static let shared = APIService()

    // Change this to your Mac's IP address if testing on physical device
    // Find it with: ipconfig getifaddr en0
    private let baseURL = "http://localhost:8080/api"

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private init() {}

    // MARK: - Private Helpers

    private func makeRequest(endpoint: String, method: String = "GET", body: Data? = nil, requiresAuth: Bool = false) async throws -> (Data, URLResponse) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = await AuthManager.shared.getToken() else {
                throw APIServiceError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        do {
            return try await URLSession.shared.data(for: request)
        } catch {
            throw APIServiceError.networkError(error)
        }
    }

    private func handleResponse<T: Decodable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponse
        }

        // Check for error status codes
        if httpResponse.statusCode >= 400 {
            // Try to decode error message
            if let apiError = try? decoder.decode(APIError.self, from: data) {
                throw APIServiceError.httpError(httpResponse.statusCode, apiError.reason)
            } else {
                throw APIServiceError.httpError(httpResponse.statusCode, "Unknown error")
            }
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIServiceError.decodingError(error)
        }
    }

    // MARK: - Authentication

    func register(username: String, displayName: String, email: String, password: String, bio: String? = nil) async throws -> AuthResponse {
        let request = RegisterRequest(username: username, displayName: displayName, email: email, password: password, bio: bio)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "auth/register", method: "POST", body: body)
        return try handleResponse(data, response)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "auth/login", method: "POST", body: body)
        return try handleResponse(data, response)
    }

    func getCurrentUser() async throws -> UserResponse {
        let (data, response) = try await makeRequest(endpoint: "auth/me", requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - Posts

    func getPosts() async throws -> [PostResponse] {
        let (data, response) = try await makeRequest(endpoint: "posts", requiresAuth: true)
        return try handleResponse(data, response)
    }

    func getPost(id: String) async throws -> PostResponse {
        let (data, response) = try await makeRequest(endpoint: "posts/\(id)")
        return try handleResponse(data, response)
    }

    func createPost(action: String, subject: String, content: String? = nil, imageURL: String? = nil) async throws -> PostResponse {
        let request = CreatePostRequest(action: action, subject: subject, content: content, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "posts", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func updatePost(id: String, content: String? = nil, imageURL: String? = nil) async throws -> PostResponse {
        let request = UpdatePostRequest(content: content, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "posts/\(id)", method: "PUT", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func deletePost(id: String) async throws {
        let (_, response) = try await makeRequest(endpoint: "posts/\(id)", method: "DELETE", requiresAuth: true)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw APIServiceError.invalidResponse
        }
    }

    func likePost(id: String) async throws -> PostResponse {
        let (data, response) = try await makeRequest(endpoint: "posts/\(id)/like", method: "POST", requiresAuth: true)
        return try handleResponse(data, response)
    }

    func unlikePost(id: String) async throws -> PostResponse {
        let (data, response) = try await makeRequest(endpoint: "posts/\(id)/like", method: "DELETE", requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - Topics

    func getTopics() async throws -> [TopicResponse] {
        let (data, response) = try await makeRequest(endpoint: "topics")
        return try handleResponse(data, response)
    }

    func getTopic(id: String) async throws -> TopicResponse {
        let (data, response) = try await makeRequest(endpoint: "topics/\(id)")
        return try handleResponse(data, response)
    }

    func createTopic(name: String, description: String) async throws -> TopicResponse {
        let request = CreateTopicRequest(name: name, topicDescription: description)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "topics", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - Topic Posts

    func getTopicPosts(topicID: String) async throws -> [TopicPostResponse] {
        let (data, response) = try await makeRequest(endpoint: "topics/\(topicID)/posts")
        return try handleResponse(data, response)
    }

    func getTopicPost(id: String) async throws -> TopicPostResponse {
        let (data, response) = try await makeRequest(endpoint: "topicposts/\(id)")
        return try handleResponse(data, response)
    }

    func createTopicPost(topicID: String, content: String) async throws -> TopicPostResponse {
        let request = CreateTopicPostRequest(content: content)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "topics/\(topicID)/posts", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func updateTopicPost(id: String, content: String) async throws -> TopicPostResponse {
        let request = UpdateTopicPostRequest(content: content)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "topicposts/\(id)", method: "PUT", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func deleteTopicPost(id: String) async throws {
        let (_, response) = try await makeRequest(endpoint: "topicposts/\(id)", method: "DELETE", requiresAuth: true)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw APIServiceError.invalidResponse
        }
    }

    func likeTopicPost(id: String) async throws -> TopicPostResponse {
        let (data, response) = try await makeRequest(endpoint: "topicposts/\(id)/like", method: "POST", requiresAuth: true)
        return try handleResponse(data, response)
    }

    func unlikeTopicPost(id: String) async throws -> TopicPostResponse {
        let (data, response) = try await makeRequest(endpoint: "topicposts/\(id)/like", method: "DELETE", requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - Comments

    func getPostComments(postID: String) async throws -> [CommentResponse] {
        let (data, response) = try await makeRequest(endpoint: "posts/\(postID)/comments")
        return try handleResponse(data, response)
    }

    func getTopicPostComments(topicPostID: String) async throws -> [CommentResponse] {
        let (data, response) = try await makeRequest(endpoint: "topicposts/\(topicPostID)/comments")
        return try handleResponse(data, response)
    }

    func createPostComment(postID: String, content: String) async throws -> CommentResponse {
        let request = CreateCommentRequest(content: content)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "posts/\(postID)/comments", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func createTopicPostComment(topicPostID: String, content: String) async throws -> CommentResponse {
        let request = CreateCommentRequest(content: content)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "topicposts/\(topicPostID)/comments", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func deleteComment(id: String) async throws {
        let (_, response) = try await makeRequest(endpoint: "comments/\(id)", method: "DELETE", requiresAuth: true)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw APIServiceError.invalidResponse
        }
    }

    // MARK: - Entities

    func getEntities() async throws -> [EntityResponse] {
        let (data, response) = try await makeRequest(endpoint: "entities")
        return try handleResponse(data, response)
    }

    func getEntity(id: String) async throws -> EntityResponse {
        let (data, response) = try await makeRequest(endpoint: "entities/\(id)")
        return try handleResponse(data, response)
    }

    func createEntity(name: String, address: String, imageURL: String? = nil) async throws -> EntityResponse {
        let request = CreateEntityRequest(name: name, address: address, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "entities", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func updateEntity(id: String, name: String? = nil, address: String? = nil, imageURL: String? = nil) async throws -> EntityResponse {
        let request = UpdateEntityRequest(name: name, address: address, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "entities/\(id)", method: "PUT", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - Events

    func getEvents() async throws -> [EventResponse] {
        let (data, response) = try await makeRequest(endpoint: "events")
        return try handleResponse(data, response)
    }

    func getEvent(id: String) async throws -> EventResponse {
        let (data, response) = try await makeRequest(endpoint: "events/\(id)")
        return try handleResponse(data, response)
    }

    func createEvent(name: String, date: Date, entityID: String, description: String? = nil, link: String? = nil, imageURL: String? = nil) async throws -> EventResponse {
        let request = CreateEventRequest(name: name, date: date, entityID: entityID, eventDescription: description, link: link, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "events", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func updateEvent(id: String, name: String? = nil, date: Date? = nil, description: String? = nil, link: String? = nil, imageURL: String? = nil) async throws -> EventResponse {
        let request = UpdateEventRequest(name: name, date: date, eventDescription: description, link: link, imageURL: imageURL)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "events/\(id)", method: "PUT", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    // MARK: - List Items

    func getListItems() async throws -> [ListItemResponse] {
        let (data, response) = try await makeRequest(endpoint: "list", requiresAuth: true)
        return try handleResponse(data, response)
    }

    func createListItem(action: String, subject: String, isPublic: Bool) async throws -> ListItemResponse {
        let request = CreateListItemRequest(action: action, subject: subject, isPublic: isPublic)
        let body = try encoder.encode(request)

        let (data, response) = try await makeRequest(endpoint: "list", method: "POST", body: body, requiresAuth: true)
        return try handleResponse(data, response)
    }

    func deleteListItem(id: String) async throws {
        let (_, response) = try await makeRequest(endpoint: "list/\(id)", method: "DELETE", requiresAuth: true)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw APIServiceError.invalidResponse
        }
    }

    // MARK: - Users

    func getUser(id: String) async throws -> UserResponse {
        let (data, response) = try await makeRequest(endpoint: "users/\(id)")
        return try handleResponse(data, response)
    }

    func getUserPosts(userID: String) async throws -> [PostResponse] {
        let (data, response) = try await makeRequest(endpoint: "users/\(userID)/posts", requiresAuth: true)
        return try handleResponse(data, response)
    }
}
