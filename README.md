# GitRepoApp

A simple iOS application that fetches and displays GitHub repositories and their latest commits using the GitHub API. This project was built to demonstrate iOS development skills, architectural patterns, and programmatic UI implementation.

## Requirements Checklist

- [x] **iOS 15+ Support**: Deployment target is set to iOS 15.6.
- [x] **No 3rd Party Libraries**: Built using only standard libraries (UIKit, Foundation).
- [x] **UIKit Implementation**: 100% programmatic UIKit (no SwiftUI).
- [x] **Task 1 (GitHub API)**: Lists public repositories for a user.
- [x] **Task 2 (Async Commits)**: Asynchronously fetches the last commit for each repo.
- [x] **Task 3 (Custom UI)**: Custom `UITableViewCell` design with layers and animations.
- [x] **Bonus**:
    - Explicit loading state tracking with `loadingCommits` (distinguishes loading, failed, no commits)
    - Custom cell corner radii for a polished UI
    - Smooth commit label update animations
    - Pull-to-refresh support
- [x] **Performance**: Helper threading and caching strategies to maintain scrolling performance.

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: `Repository`, `Commit` (Data structures codable from JSON).
- **Network**: `APIClient` (Generic network layer) and `GitHubService` (Domain-specific API calls).
- **ViewModel**: `RepositoryListViewModel` (Manages state, fetches data, and processes business logic).
- **View**: `RepositoryListViewController` and `RepositoryCell` (Programmatic UI implementation).

## Technical Decisions & Trade-offs

### 1. UIKit & Programmatic UI
Per the requirements, **SwiftUI was avoided**. I wrote the UI programmatically using Auto Layout anchors.

### 2. Threading & Performance
- **Network Requests**: Executed on background threads via `URLSession`.
- **UI Updates**: Explicitly dispatched to `DispatchQueue.main` in the Service layer to ensure thread safety.
- **Scrolling Performance**:
    - **Cell Reuse**: Standard `dequeueReusableCell` is used.
    - **Async Image/Data Loading**: Commit data is fetched lazily. The `RepositoryCell` has a loading state to prevent UI blocking.
    - **N+1 Problem**: The current API requirement involves fetching the list first (1 call) and then the last commit for *each* repository (N calls). In a large production app, this would be inefficient (rate limits, battery drain). I implemented this as requested but mitigated the UX impact by loading commits independently and updating specific rows (`reloadRows`) as data comes in, rather than reloading the whole table.
    - **Pagination**: The current app loads all repos at once. A production app would likely need pagination (scrolling to load more) to handle large datasets efficiently.
    - **Debugging**: Print statements (e.g., in `RepositoryListViewModel.swift` and `APIClient.swift`) have been commented out but left in the code to demonstrate the flow of data fetching during development. In a production build, these would be removed or replaced with a logging framework.

### 3. Error Handling
Basic error handling is implemented using Swift's `Result` type. Errors are propagated from the Network layer to the ViewModel, which exposes a `ViewState.error` state to the ViewController for alert presentation.

### 4. Security Note
> [!NOTE]
> **Authentication**: The project originally used a Personal Access Token (PAT) for development to avoid GitHub API rate limits. 
> 
> **For this submission, the token has been removed.**
> If you run the app and encounter rate limit errors (403), please refer to the comments in `APIClient.swift` for instructions on how to temporarily add your own token or reduce the request volume.
