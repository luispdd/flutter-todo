# Technical Design: Initial Flutter To-Do Application (`init-todo-app`)

## 1. Architecture Overview
The application follows a clean Layered Architecture ensuring clear separation of concerns, testability, and portability across Linux Desktop and Android:

```
lib/
├── models/         # Pure Dart data entities & JSON serialization
├── services/       # Persistent storage & Clipboard interaction
├── controllers/    # State management & business logic (ChangeNotifier)
└── views/          # Material 3 UI widgets, screens, and dialogs
```

---

## 2. Data Models & JSON Schemas

### 2.1 Category Model (`Category`)
- `id`: `String` (Unique UUID)
- `name`: `String` (Display title)
- `colorValue`: `int` (ARGB integer for custom color theme)
- `iconCodePoint`: `int` (Material Icon code point)
- `order`: `int` (Sort order index)
- `createdAt`: `DateTime` (Creation timestamp)

### 2.2 To-Do Item Model (`TodoItem`)
- `id`: `String` (Unique UUID)
- `categoryId`: `String` (Foreign key referencing `Category.id`)
- `title`: `String` (Task title)
- `description`: `String` (Optional Markdown/plain text notes)
- `isCompleted`: `bool` (Active vs Completed flag)
- `order`: `int` (Position in active or completed list)
- `createdAt`: `DateTime` (Creation timestamp)
- `completedAt`: `DateTime?` (Timestamp when marked complete)
- `dueDate`: `DateTime?` (Optional deadline)

### 2.3 Application Data Root (`AppData`)
- `schemaVersion`: `int` (Version integer, default `1`)
- `exportedAt`: `DateTime` (ISO 8601 string when exported)
- `categories`: `List<Category>`
- `todos`: `List<TodoItem>`

---

## 3. State Management & Controllers

### `TodoController` (`ChangeNotifier`)
- **Category State**:
  - `List<Category> get categories`
  - `Category? get selectedCategory`
  - `void addCategory(Category category)`
  - `void updateCategory(Category category)`
  - `void deleteCategory(String categoryId)` (cascades deletion to associated tasks)
  - `void reorderCategories(int oldIndex, int newIndex)`
- **Task State (Filtered per Category)**:
  - `List<TodoItem> getActiveTodos(String categoryId)`
  - `List<TodoItem> getCompletedTodos(String categoryId)`
  - `void addTodo(TodoItem item)`
  - `void updateTodo(TodoItem item)`
  - `void toggleComplete(String todoId)`
  - `void reorderActiveTodos(String categoryId, int oldIndex, int newIndex)`
  - `void reorderCompletedTodos(String categoryId, int oldIndex, int newIndex)`
- **Multi-Selection State**:
  - `Set<String> get selectedActiveIds`
  - `Set<String> get selectedCompletedIds`
  - `bool get isSelectionModeActive`
  - `void toggleSelection(String id, {required bool isCompleted})`
  - `void selectAll(String categoryId, {required bool isCompleted})`
  - `void clearSelection()`
  - `void completeSelected()`
  - `void restoreSelectedToActive()`
  - `void deleteSelectedPermanently({required bool isCompleted})`
- **Clipboard & Persistence**:
  - `Future<void> loadFromStorage()`
  - `Future<void> saveToStorage()`
  - `String exportToJson()`
  - `Future<bool> importFromJson(String jsonStr, {bool merge = false})`

---

## 4. Services

### `StorageService`
- Persists the entire serialized `AppData` locally using `shared_preferences` / local JSON storage.
- Auto-saves state upon mutations.

### `ClipboardService`
- `Future<void> copyToClipboard(String jsonStr)`
- `Future<String?> pasteFromClipboard()`
- `ValidationResult validateJson(String jsonStr)`: Validates JSON format and schema before applying.

---

## 5. User Interface & Interaction Flow

1. **Categories Screen (Home)**:
   - Modern grid/list of categories with color badge, icon, task counter (e.g., `3 active / 8 done`), and progress bar.
   - Quick Category edit / delete dialog.
   - Header actions: Theme toggle (Light/Dark), Search/Filter, Clipboard Import/Export button.
   - FAB: Create New Category.
2. **Category Tasks Hub Screen**:
   - Dynamic AppBar: Normal mode displays Category title, progress indicator, and action buttons. Multi-select mode displays selected count, Select All, Batch Complete/Restore, and Batch Delete.
   - Segmented Tab Bar: **Active Tasks** vs. **Completed Tasks**.
3. **Active Tasks View**:
   - `ReorderableListView` with drag handles.
   - Item row: Checkbox, Drag Handle, Title, Due Date badge, Notes indicator, Edit action.
   - Long press or checkbox trigger enables multi-select mode.
4. **Completed Tasks View**:
   - `ReorderableListView` for completed tasks.
   - Item row: Uncheck/Restore icon button, Drag Handle, Strikethrough title, Completed timestamp, Permanent Delete action.
   - Multi-select allows bulk restore or bulk permanent delete.
5. **Clipboard Import / Export Dialog**:
   - **Export Tab**: Live JSON code preview + "Copy to Clipboard" with instant feedback.
   - **Import Tab**: "Paste from Clipboard" + Real-time schema validation + "Replace All" vs "Merge with Existing" options.

---

## 6. Platform Specifics (Linux Desktop & Android)
- **Linux Desktop**: Responsive layout with desktop-appropriate touch targets, mouse hover states, cursor styles, and keyboard shortcuts.
- **Android**: Material 3 fluid animations, touch gestures, haptic feedback on drag reordering.
