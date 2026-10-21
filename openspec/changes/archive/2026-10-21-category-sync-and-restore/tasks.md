## 1. Dependencies & Data Models

- [x] 1.1 Add `http: ^1.2.0` to `pubspec.yaml` and verify installation succeeds via `flutter pub get`
- [x] 1.2 Add `isApiSyncEnabled` (bool, default `false`) to `Category` in `lib/models/category.dart`, updating `toJson`, `fromJson`, `copyWith`, and verify static analysis passes

## 2. Completed Tasks Typography

- [x] 2.1 Update `CompletedTasksView` in `lib/views/tasks/completed_tasks_view.dart` to remove `TextDecoration.lineThrough` and set title font weight to bold, and verify completed tasks render legibly without strike-through

## 3. Screen Navigation Persistence & Restoration

- [x] 3.1 Add `getLastActiveCategoryId`, `setLastActiveCategoryId`, and `clearLastActiveCategoryId` to `StorageService` in `lib/services/storage_service.dart`
- [x] 3.2 Update `CategoryTasksScreen` to record the active category ID on entrance and clear it when popped back to categories
- [x] 3.3 Update `CategoriesScreen` to check for a stored active category ID on launch and navigate directly to `CategoryTasksScreen` post-frame while preserving `CategoriesScreen` in the backstack

## 4. Screen API Service

- [x] 4.1 Create `ScreenApiService` in `lib/services/screen_api_service.dart` implementing `fetchTasks()`, `deleteTask(int id)`, and `createTasks(List<String> texts)` targeting `http://screen.local` with a 7-second timeout and robust exception handling

## 5. UI Integration & Sync Workflows

- [x] 5.1 Update `CategoryDialog` in `lib/views/categories/category_dialog.dart` to display an "Activate API sync" switch tile, returning the selection upon save
- [x] 5.2 Update `CategoryTasksScreen` in `lib/views/tasks/category_tasks_screen.dart` to display `[ Pull from API ] [ Push to API ] [ + Add Task ]` when `isApiSyncEnabled` is true
- [x] 5.3 Implement the "Push to API" action: fetch remote tasks, delete each remote task, batch create local active tasks on the appliance, and display status feedback via SnackBar
- [x] 5.4 Implement the "Pull from API" action: prompt confirmation dialog, fetch remote tasks, clear current local category tasks, populate local active/completed tasks, and display status feedback via SnackBar

## 6. Verification & Quality Assurance

- [x] 6.1 Run `flutter analyze` and `flutter test` to ensure zero compilation warnings or test failures across the project
