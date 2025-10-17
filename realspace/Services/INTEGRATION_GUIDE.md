# API Integration Guide

## Overview
Your API service layer is now complete! Here's how to integrate it into your iOS app.

## What's Been Created

1. **APIModels.swift** - All DTOs matching your backend API
2. **AuthManager.swift** - JWT token storage using Keychain
3. **APIService.swift** - Complete API client with all endpoints

## Quick Start

### 1. Start the Backend API
```bash
cd realspace-API
swift run RealspaceApi serve --hostname 0.0.0.0 --port 8080
```

### 2. Configure Base URL (if testing on physical device)
Edit `APIService.swift` line 15:
```swift
private let baseURL = "http://YOUR_MAC_IP:8080/api"
```
Find your Mac's IP: `ipconfig getifaddr en0`

## Integration Pattern

### Authentication Flow

```swift
// In your LoginViewModel
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared
    private let authManager = AuthManager.shared

    func login() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            authManager.login(token: response.token, user: response.user)
            // Navigate to main app
        } catch let error as APIServiceError {
            switch error {
            case .httpError(_, let message):
                errorMessage = message
            case .unauthorized:
                errorMessage = "Invalid credentials"
            case .networkError:
                errorMessage = "Network error. Is the API running?"
            default:
                errorMessage = "An error occurred"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func register() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.register(
                username: username,
                displayName: displayName,
                email: email,
                password: password,
                bio: bio
            )
            authManager.login(token: response.token, user: response.user)
            // Navigate to main app
        } catch {
            // Handle error
        }

        isLoading = false
    }
}
```

### Fetching Data (Example: Posts)

```swift
@MainActor
class CommunityViewModel: ObservableObject {
    @Published var posts: [PostResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            posts = try await apiService.getPosts()
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func createPost(action: String, subject: String, content: String?) async {
        do {
            let newPost = try await apiService.createPost(
                action: action,
                subject: subject,
                content: content
            )
            posts.insert(newPost, at: 0) // Add to top of list
        } catch {
            errorMessage = "Failed to create post"
        }
    }

    func likePost(_ post: PostResponse) async {
        do {
            let updatedPost = try await apiService.likePost(id: post.id)
            // Update the post in your array
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index] = updatedPost
            }
        } catch {
            errorMessage = "Failed to like post"
        }
    }
}
```

### Using in Views

```swift
struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        List {
            ForEach(viewModel.posts, id: \.id) { post in
                PostRow(post: post)
            }
        }
        .task {
            await viewModel.loadPosts()
        }
        .refreshable {
            await viewModel.loadPosts()
        }
    }
}
```

## Step-by-Step Integration

### 1. Update Your App Entry Point

Add AuthManager to environment:

```swift
@main
struct realspaceApp: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
```

### 2. Update ViewModels

For each ViewModel that needs data from the API:

1. Replace SwiftData queries with API calls
2. Add loading state: `@Published var isLoading = false`
3. Add error handling: `@Published var errorMessage: String?`
4. Use `Task { await viewModel.method() }` in views

### 3. Remove SwiftData (Optional)

Since you're now using the API, you can:
- Remove `@Query` from your views
- Remove SwiftData model files (keep as reference if needed)
- Remove modelContainer from your app

## API Endpoints Reference

### Authentication
- `register()` - Create new account
- `login()` - Login with email/password
- `getCurrentUser()` - Get current user info

### Posts
- `getPosts()` - List all posts
- `getPost(id:)` - Get single post
- `createPost()` - Create new post
- `updatePost(id:)` - Update post
- `deletePost(id:)` - Delete post
- `likePost(id:)` - Like a post
- `unlikePost(id:)` - Unlike a post

### Topics
- `getTopics()` - List topics
- `getTopic(id:)` - Get single topic
- `createTopic()` - Create topic

### Topic Posts
- `getTopicPosts(topicID:)` - Posts in topic
- `createTopicPost(topicID:)` - Create post in topic
- `updateTopicPost(id:)` - Update topic post
- `deleteTopicPost(id:)` - Delete topic post
- `likeTopicPost(id:)` / `unlikeTopicPost(id:)` - Like/unlike

### Comments
- `getPostComments(postID:)` - Comments on post
- `getTopicPostComments(topicPostID:)` - Comments on topic post
- `createPostComment(postID:)` - Add comment to post
- `createTopicPostComment(topicPostID:)` - Add comment to topic post
- `deleteComment(id:)` - Delete comment

### Entities & Events
- `getEntities()` / `getEntity(id:)`
- `createEntity()` / `updateEntity(id:)`
- `getEvents()` / `getEvent(id:)`
- `createEvent()` / `updateEvent(id:)`

### List Items
- `getListItems()` - User's list
- `createListItem()` - Add to list
- `deleteListItem(id:)` - Remove from list

### Users
- `getUser(id:)` - Get user profile
- `getUserPosts(userID:)` - User's posts

## Error Handling

All API methods throw errors. Handle them appropriately:

```swift
do {
    let result = try await apiService.someMethod()
    // Success
} catch let error as APIServiceError {
    switch error {
    case .httpError(let code, let message):
        // Server returned error
    case .unauthorized:
        // Token expired or invalid
        authManager.logout()
    case .networkError:
        // Network connectivity issue
    case .decodingError:
        // Response format unexpected
    default:
        // Other error
    }
} catch {
    // Unexpected error
}
```

## Testing

1. Start the API: `swift run RealspaceApi serve`
2. Run your iOS app in simulator
3. Register a new account
4. Create a post
5. Like the post
6. Add comments

## Troubleshooting

**"Connection refused"**
- Make sure API is running on port 8080
- Check firewall settings

**"Unauthorized" errors**
- Token may have expired (30 days)
- Try logging out and back in

**Physical device not connecting**
- Update baseURL in APIService.swift with your Mac's IP
- Ensure both devices on same WiFi network

## Next Steps

1. Update LoginViewModel (example provided above)
2. Update CommunityViewModel for posts
3. Update TopicsViewModel for topics
4. Update other ViewModels as needed
5. Test the complete flow

The API service layer handles all the networking, JSON encoding/decoding, authentication headers, and error handling for you!
