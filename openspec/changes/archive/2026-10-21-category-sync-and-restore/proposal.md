## Why

Users who organize tasks within specific categories frequently reopen the app to continue working where they left off; currently, the app always opens to the category overview list, requiring repetitive navigation. Additionally, completed tasks have line-through styling that hinders readability. Finally, users with standalone physical e-paper/LCD to-do hardware appliances (running the ESP32 To-Do REST API) need direct two-way synchronization with a chosen category to push pending tasks to the device display and pull appliance tasks back into the app.

## What Changes

- **Category Screen Persistence & Restoration**: Persist the currently viewed category ID upon entering `CategoryTasksScreen`. When launching the application, if a valid active category is recorded, start directly in that category view while preserving the main categories screen in the backstack.
- **Completed Tasks Typography**: Remove the line-through strike-through decoration from completed task titles in `CompletedTasksView` and render the font weight as bold (`FontWeight.bold` / `FontWeight.w600`) to match the readability of the active task list.
- **Category API Sync Option**: Add an "Activate API sync" toggle in the Edit Category dialog and store this flag in the `Category` model.
- **Screen API Client & Sync Workflows**: Add `package:http` and introduce a client communicating with `http://screen.local`:
  - **Push to API**: Clear all existing tasks on the appliance (`GET /tasks` then `DELETE /tasks/{id}` for each) and send all pending (active) tasks from the current category (`POST /tasks`).
  - **Pull from API**: Clear all local tasks in the current category, retrieve all tasks from the appliance (`GET /tasks`), and insert them as active or completed tasks according to their remote `done` state.
- **Category Screen Sync Controls**: In `CategoryTasksScreen`, when API sync is active for the category, display a horizontal action row next to the floating action button: `[ Pull from API ] [ Push to API ] [ + Add Task ]`.

## Capabilities

### New Capabilities
- `screen-api-sync`: Synchronization of category tasks with the ESP32 To-Do appliance REST API at `http://screen.local`, supporting "Push to API" (replace remote with local pending tasks) and "Pull from API" (replace local with remote tasks).

### Modified Capabilities
- `categories`: Category model and dialog support for the `isApiSyncEnabled` configuration, and automatic navigation restoration to the last viewed category on startup.
- `tasks`: Completed tasks list typography styling update to eliminate strike-through and use bold font for enhanced legibility.

## Impact

- **Dependencies**: Add `http: ^1.2.0` to `pubspec.yaml`.
- **Models**: Add `isApiSyncEnabled` (bool, default `false`) to `Category` (`toJson`, `fromJson`, `copyWith`).
- **Storage**: Add persistence for `last_active_category_id` in `SharedPreferences` via `StorageService`.
- **Views**: Update `CategoriesScreen` / `CategoryTasksScreen` for navigation persistence and sync action buttons; update `CategoryDialog` with sync toggle switch; update `CompletedTasksView` title text styling.
- **Services**: Introduce `ScreenApiService` to handle communication with `http://screen.local`.
