## Context

See `proposal.md` for problem background and requirements. The application uses `Provider` with `TodoController`, persisting data as JSON via `StorageService` using `SharedPreferences`. The target hardware appliance serves a REST API defined in `openapi.yaml` over local Wi-Fi at `http://screen.local:80`.

## Goals / Non-Goals

**Goals:**
- Provide reliable screen restoration to the active category without breaking the navigation backstack.
- Update completed task titles in `CompletedTasksView` to bold text without line-through decoration.
- Add an explicit toggle in the Category dialog to enable API synchronization.
- Implement robust Push (replace remote with local pending tasks) and Pull (replace local with remote tasks) operations using a dedicated `ScreenApiService`.
- Display a clean horizontal action button group `[ Pull from API ] [ Push to API ] [ + Add Task ]` when sync is enabled.

**Non-Goals:**
- Real-time background sync or polling daemons.
- Multi-master merging or CRDT conflict resolution (Push and Pull are explicit full replacements as specified).
- Dynamic IP discovery or Bonjour browsing outside the standard `http://screen.local` endpoint.

## Decisions

### 1. Dedicated `ScreenApiService` for Appliance Communication
- **Decision**: Encapsulate all HTTP communication inside `lib/services/screen_api_service.dart` using `package:http`.
- **Rationale**: Keeps network handling, JSON serialization, timeout enforcement (7-second timeout), and error translation separated from the UI and `TodoController`.
- **Alternatives considered**: Inlining HTTP calls in `TodoController` (rejected for violation of single-responsibility and harder testing).

### 2. Push & Pull Lifecycle Implementation
- **Push Flow**:
  1. `GET http://screen.local/tasks` to discover currently stored remote task IDs.
  2. For each task ID, send `DELETE http://screen.local/tasks/{id}`.
  3. Format all active (pending) tasks of the current category as `[{"text": task.title}, ...]`.
  4. Send a single batch `POST http://screen.local/tasks` (as required by the OpenAPI spec).
- **Pull Flow**:
  1. Show a confirmation dialog to the user before deleting local tasks.
  2. `GET http://screen.local/tasks`.
  3. Delete all existing tasks in the category locally.
  4. Insert each remote task into `TodoController`, mapping `done: false` to active tasks and `done: true` to completed tasks.

### 3. Navigation State Restoration via SharedPreferences
- **Decision**: Save `last_active_category_id` in `SharedPreferences` when navigating into `CategoryTasksScreen`. When user navigates back (via `WillPopScope`/`PopScope` or back button), clear `last_active_category_id`.
- **Restoration Mechanism**: In `CategoriesScreen.initState()`, check if `last_active_category_id` exists in storage and matches a current category. If so, schedule a `Navigator.push` in a post-frame callback (`addPostFrameCallback`).
- **Rationale**: Preserves `CategoriesScreen` directly underneath in the navigation stack, allowing the user to naturally press the back button to view all categories.
- **Alternatives considered**: Conditionally setting `home:` in `MaterialApp` to `CategoryTasksScreen` (rejected because popping would exit the application rather than returning to the category overview).

### 4. Floating Action Area Layout
- **Decision**: In `CategoryTasksScreen`, replace the single FAB with a horizontal `Row` of action buttons when `category.isApiSyncEnabled` is active:
  - `FilledButton.icon` or `FloatingActionButton.extended` for `Pull from API`
  - `FilledButton.icon` or `FloatingActionButton.extended` for `Push to API`
  - Standard primary `FloatingActionButton.extended` for `Add Task`
- **Alternatives considered**: Placing sync buttons in the `AppBar` (rejected because the user explicitly requested buttons next to the "Add task" button).

### 5. Typography Adjustment in Completed Tasks
- **Decision**: In `lib/views/tasks/completed_tasks_view.dart`, remove `decoration: TextDecoration.lineThrough` and change `fontWeight` from `FontWeight.w500` to `FontWeight.bold` (matching `FontWeight.w600`/bold in active tasks). Keep secondary info (completion timestamp and muted color) so completed status remains distinct.

## Risks / Trade-offs

- **[Risk] Appliance unreachable or network timeout** &rarr; Enforce a 7-second timeout with friendly SnackBar error reporting ("Unable to connect to screen at http://screen.local"). Local tasks remain untouched on failed push/pull.
- **[Risk] Stale saved category ID on launch** (e.g. category deleted or data reset) &rarr; Safe lookup via `controller.getCategoryById(savedId)`; if `null`, simply clear the preference and remain on `CategoriesScreen`.
- **[Risk] Accidental data loss on Pull** &rarr; Display a confirmation alert dialog before wiping local category tasks during a pull operation.
