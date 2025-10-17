# FriendsViewModel Update Guide

## ✅ What Changed

The `FriendsViewModel` has been updated to use the API instead of SwiftData.

### Key Changes:

1. **Removed SwiftData dependency**
   - No more `ModelContext`
   - No more `configure(with:)` method

2. **Added API integration**
   - Uses `APIService.shared` for all data operations
   - All methods are now `async`

3. **Added new published properties**
   - `@Published var posts: [PostResponse]` - Stores posts from API
   - `@Published var isLoading` - Loading state
   - `@Published var errorMessage: String?` - Error messages
   - `@Published var isCreatingPost` - Post creation state

4. **Updated method signatures**
   - `createPost()` - Now `async`, no longer needs `author` parameter
   - Added `loadPosts()` - Fetches posts from API
   - Added `likePost(_:)` - Like/unlike functionality
   - Added `deletePost(_:)` - Delete post functionality

## 📝 How to Update Your View

### Before (SwiftData version):
```swift
struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    @StateObject private var viewModel = FriendsViewModel()

    var body: some View {
        // ...
        Button("Post") {
            viewModel.createPost(author: currentUser)
        }
    }

    .onAppear {
        viewModel.configure(with: modelContext)
    }
}
```

### After (API version):
```swift
struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack {
            // Show loading indicator
            if viewModel.isLoading {
                ProgressView()
            }

            // Show error if any
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            // List of posts
            List(viewModel.posts, id: \.id) { post in
                PostRow(post: post, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.loadPosts()
            }

            // Create post button
            Button("Post") {
                Task {
                    await viewModel.createPost()
                }
            }
            .disabled(viewModel.isCreatingPost || !viewModel.canPost)
        }
        .task {
            // Load posts when view appears
            await viewModel.loadPosts()
        }
    }
}

struct PostRow: View {
    let post: PostResponse
    let viewModel: FriendsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            // Post content
            Text("\(post.author.displayName) \(post.action) \(post.subject)")

            if let content = post.content {
                Text(content)
                    .font(.caption)
            }

            // Like button
            HStack {
                Button {
                    Task {
                        await viewModel.likePost(post)
                    }
                } label: {
                    HStack {
                        Image(systemName: post.isLikedByCurrentUser == true ? "heart.fill" : "heart")
                        Text("\(post.likesCount)")
                    }
                }

                if let commentsCount = post.commentsCount {
                    Text("\(commentsCount) comments")
                }
            }
        }
    }
}
```

## 🔑 Key Patterns to Use

### 1. Loading Data on View Appear
```swift
.task {
    await viewModel.loadPosts()
}
```

### 2. Pull to Refresh
```swift
.refreshable {
    await viewModel.loadPosts()
}
```

### 3. Button Actions (async)
```swift
Button("Post") {
    Task {
        await viewModel.createPost()
    }
}
```

### 4. Show Loading State
```swift
if viewModel.isLoading {
    ProgressView()
}
```

### 5. Show Error Messages
```swift
if let error = viewModel.errorMessage {
    Text(error)
        .foregroundColor(.red)
}
```

### 6. Disable Button While Loading
```swift
.disabled(viewModel.isCreatingPost || !viewModel.canPost)
```

## 📊 Available Data

The `posts` array now contains `PostResponse` objects with:
- `id: String` - Post UUID
- `action: String` - "watched", "read", "went to"
- `subject: String` - What they watched/read
- `content: String?` - Optional post body
- `imageURL: String?` - Optional image
- `likesCount: Int` - Number of likes
- `createdAt: Date?` - When posted
- `author: UserSummary` - Author info (id, username, displayName)
- `isLikedByCurrentUser: Bool?` - Did current user like it?
- `commentsCount: Int?` - Number of comments

## 🎯 What to Remove

Remove these from your view:
- `@Environment(\.modelContext)`
- `@Query` for posts
- `.onAppear { viewModel.configure(with: modelContext) }`
- Any references to the old `Post` SwiftData model

## ✨ New Features Available

Now you can:
1. **Like/Unlike posts** - `await viewModel.likePost(post)`
2. **Delete posts** - `await viewModel.deletePost(post)`
3. **Pull to refresh** - Built into the view
4. **See real-time like counts** - From the API
5. **See comment counts** - From the API
6. **See which posts you liked** - `isLikedByCurrentUser`

## 🐛 Common Issues

**"Network error"**
- Make sure API is running: `swift run RealspaceApi serve`
- Check base URL in `APIService.swift`

**"Please log in again"**
- User is not authenticated
- Call `AuthManager.shared.logout()` and show login screen

**Posts not showing**
- Check if `await viewModel.loadPosts()` is being called
- Look for error messages in `viewModel.errorMessage`
