# Realspace iOS App

## Overview

Realspace is a social media iOS application built with SwiftUI and SwiftData that focuses on sharing experiences about media (movies, books) and real-world places. It combines elements of Letterboxd, Goodreads, and local events platforms to create a community-driven experience discovery app.

## Tech Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS Version**: 17.6
- **Xcode Version**: 26.0

## Project Structure

```
realspace/
├── Model/
│   ├── User.swift           - User profiles with posts and relationships
│   ├── Post.swift           - User activity posts (watched/read/went to)
│   ├── Comment.swift        - Comments on posts and topic posts
│   ├── Topic.swift          - Discussion topics (e.g., "Film & Cinema")
│   ├── TopicPost.swift      - Posts within specific topics
│   ├── Entity.swift         - Physical locations (cafes, theaters, etc.)
│   ├── Event.swift          - Events at entities
│   └── ListItem.swift       - Personal to-do list items
├── View/
│   ├── LoginView.swift      - Simple login screen (no auth yet)
│   ├── MainTabView.swift    - Tab navigation container
│   ├── FriendsView.swift    - Main feed of friends' posts
│   ├── CommunityView.swift  - Local events feed
│   ├── TopicsView.swift     - List of discussion topics
│   ├── TopicFeedView.swift  - Posts within a specific topic
│   └── ListView.swift       - Personal to-do list
├── ViewModel/
│   ├── LoginViewModel.swift
│   ├── FriendsViewModel.swift
│   ├── CommunityViewModel.swift
│   ├── TopicsViewModel.swift
│   ├── TopicFeedViewModel.swift
│   └── ListViewModel.swift
├── Utilities/
│   ├── Typography.swift     - Custom font styles
│   └── PreviewHelper.swift  - Preview data and scenarios
└── realspaceApp.swift       - App entry point with SwiftData setup
```

## Data Models

### Core Models (SwiftData @Model classes)

**User**
- `id: UUID` - Unique identifier
- `username: String` - Handle (e.g., @alice)
- `displayName: String` - Full name
- `bio: String` - User bio
- `profileImageURL: String?` - Profile picture URL
- Relationships: posts, likedPosts

**Post**
- `id: UUID`
- `action: String` - "watched", "read", or "went to"
- `subject: String` - What they did (e.g., "The Godfather")
- `content: String?` - Optional body text
- `imageURL: String?`
- `likesCount: Int`
- Relationships: author (User), comments

**TopicPost**
- `id: UUID`
- `content: String` - Post content
- `likesCount: Int`
- Relationships: author (User), topic (Topic), comments

**Topic**
- `id: UUID`
- `name: String` - Topic name (e.g., "Star Wars")
- `topicDescription: String`
- Relationships: posts (TopicPost[])

**Entity**
- `id: UUID`
- `name: String` - Location name (e.g., "Blue Bottle Coffee")
- `address: String`
- `imageURL: String?`

**Event**
- `id: UUID`
- `name: String` - Event name
- `date: Date`
- `eventDescription: String?`
- `link: String?` - Optional event URL
- Relationships: entity (Entity)

**ListItem**
- `id: UUID`
- `action: String` - "watch", "read", or "go to"
- `subject: String` - What the user wants to do
- Relationships: user (User)

**Comment**
- `id: UUID`
- `content: String`
- Relationships: author (User), post (Post), topicPost (TopicPost)

## Features & Functionality

### Implemented Features

1. **Tab Navigation**
   - Four main tabs: Friends, Community, Topics, List
   - Functional tab switching via bottom navigation bar
   - Shared state management across all views

2. **Friends Feed (FriendsView)**
   - Post creation with action dropdown + subject + body
   - Actions: "watched", "read", "went to"
   - Functional "Post" button (creates SwiftData objects)
   - Feed displays posts sorted by date (newest first)
   - Shows author name, action, subject, content, likes, and comment counts
   - Auto-creates sample user if none exists

3. **Topics (TopicsView & TopicFeedView)**
   - List of discussion topics with descriptions
   - Navigation to individual topic feeds
   - Post creation within topics
   - Functional "Post" button
   - Search bar (UI only, not yet functional)

4. **Community Events (CommunityView)**
   - Feed of local events sorted by date
   - Shows event name, entity/venue, date, description, address, and links
   - Events are associated with physical entities

5. **Personal List (ListView)**
   - To-do list for things user wants to watch/read/visit
   - Actions: "watch", "read", "go to"
   - Functional "Add" button
   - Items sorted by creation date

### Design System

**Typography** (Typography.swift)
- `.appTitle` - Large, bold, italic serif for "Realspace" branding
- `.postAuthor` - Medium-large serif for names
- `.postBody` - Normal serif for body text
- Consistent serif design throughout

**Color Scheme**
- Black and white primary palette
- Black borders (0.5px width) around content cards
- Gray circles for profile picture placeholders
- Black navigation bar with white text
- White highlights for active tabs

**UI Patterns**
- Consistent top banner with "Realspace" title and profile circle
- Content creation fields at top of feeds
- Black buttons with white text for actions
- Disabled state: 50% opacity
- Bottom navigation bar across all main views

## Current State & Limitations

### What Works
- ✅ Tab navigation between all four main views
- ✅ Post creation in Friends feed with SwiftData persistence
- ✅ Topic post creation with SwiftData persistence
- ✅ List item creation with SwiftData persistence
- ✅ Data persists between app launches
- ✅ Preview system with sample data
- ✅ Basic SwiftUI layouts for all views

### What's Not Implemented
- ❌ Topic search functionality
- ❌ Profile editing
- ❌ Image uploads
- ❌ User relationships (following/friends)
- ❌ Real profile pictures (gray circles only)
- ❌ Navigation from TopicFeedView back to TopicsView
- ❌ Tab navigation from TopicFeedView (shows Topics tab)

### Backend API Integration
The app is configured to connect to the Realspace API v2 backend. The following features are implemented via the API:
- ✅ User authentication (login/register)
- ✅ JWT token-based session management
- ✅ Like/unlike functionality for posts and topic posts
- ✅ Commenting on posts and topic posts
- ✅ Event creation and management
- ✅ Entity (venue) management

## Preview System

The app includes a comprehensive preview helper (`PreviewHelper.swift`) with three scenarios:

1. **Standard** - Full sample data including:
   - Sample users (Alice, Bob)
   - Sample posts with various actions
   - Topics (Film & Cinema, Literature, Star Wars, Coffee Culture)
   - Topic posts with discussions
   - Entities (coffee shops, libraries, theaters)
   - Events at entities
   - List items

2. **Empty Feed** - Single user with no content
3. **Many Posts** - One user with 20+ posts for testing scrolling

## Key Implementation Details

### SwiftData Setup
- Model container configured in `realspaceApp.swift`
- All 8 models registered in schema
- Persistent storage enabled (not in-memory)
- Model context injected via environment

### Sample User Creation
- Each view that creates content checks for existing users
- If no users exist, creates a "Sample User" with username "sampleuser"
- Uses `getCurrentUser()` helper function
- User persists across sessions

### Form Management
- Each creation view has validation (`canPost`, `canAdd`)
- Buttons disabled when required fields empty
- Forms clear automatically after successful creation
- Error handling with console logging

### Navigation
- `MainTabView` manages shared `selectedTab` state
- Each view receives `@Binding var selectedTab`
- Tab buttons update binding on tap
- Switch statement in `MainTabView` renders appropriate view

## Running the App

### Prerequisites

1. **Backend API** - The app requires the Realspace API v2 backend to be running
2. Start the backend:
   ```bash
   cd ../Realspace-API-v2/Realspace-API-v2
   dotnet run
   ```
   Or with Docker:
   ```bash
   cd ../Realspace-API-v2
   docker compose up -d
   ```

### Running the iOS App

1. Open `realspace.xcodeproj` in Xcode 26.0+
2. Select iOS Simulator (iOS 17.6+)
3. Build and run (Cmd+R)
4. Register a new account or login with existing credentials
5. The app connects to `http://localhost:8080/api` by default

### Testing on Physical Device

To test on a physical device, update the base URL in `Services/APIService.swift`:
```swift
// Change this to your Mac's IP address
private let baseURL = "http://YOUR_MAC_IP:8080/api"
```
Find your IP with: `ipconfig getifaddr en0`

## Development Notes

### Adding New Features

**To add a new post type:**
1. Create/update model in `Model/` directory
2. Add to schema in `realspaceApp.swift`
3. Update `PreviewHelper.swift` with sample data
4. Create/update corresponding view and view model

**To add navigation:**
- Update `MainTabView` switch statement
- Pass `selectedTab` binding to new views
- Implement tab button logic in navigation bar

**To add user actions (likes, comments):**
- Update model relationships
- Add button handlers in views
- Implement SwiftData updates in view models

### Common Patterns

**Creating SwiftData objects:**
```swift
let object = ModelType(params)
modelContext.insert(object)
try? modelContext.save()
```

**Querying data:**
```swift
@Query(sort: \Model.property, order: .reverse) private var items: [Model]
```

**Sample user management:**
```swift
@Query(sort: \User.createdAt) private var users: [User]
let user = users.first ?? createSampleUser()
```

## Future Considerations

### Immediate Next Steps
1. Implement like/unlike functionality
2. Add commenting system
3. Fix navigation from TopicFeedView
4. Implement search in TopicsView
5. Add user profile view
6. Implement event creation

### Long-term Goals
1. Backend API integration
2. Real authentication system
3. Image upload and storage
4. User relationships/following
5. Notifications
6. Direct messaging
7. Content moderation
8. Analytics and recommendations

## Design Philosophy

The app aims to encourage thoughtful sharing of cultural experiences and local community engagement. The design is intentionally minimal (black and white, serif fonts) to put focus on content rather than UI chrome. The structured post format (action + subject) creates consistency and makes it easy to scan activity.

## Bundle Identifier

`zach.fall2025.realspace`

## Contact & Attribution

Created by Zach Bagley on 10/3/25
