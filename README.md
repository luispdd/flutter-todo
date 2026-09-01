# Flutter To-Do App

A modern, full-featured To-Do and task management application built with [Flutter](https://flutter.dev/). Organize your daily productivity with customizable categories, intuitive drag-and-drop reordering, batch task operations, light/dark theming, and seamless JSON import/export via clipboard.

---

## ✨ Features

- 🗂️ **Custom Categories**: Create, edit, and color-code categories with custom icons and track completion progress for each category.
- 🖐️ **Drag & Drop Reordering**: Reorder categories and tasks intuitively using drag-and-drop to match your workflow.
- 📋 **Task Management**:
  - Add tasks with descriptions and due dates.
  - Separate views for **Active** and **Completed** tasks.
  - Multi-selection mode for batch operations (batch complete, batch delete, batch restore).
- 🔄 **Clipboard JSON Sync & Backup**:
  - Export complete app state into JSON format copied directly to the clipboard.
  - Import state with validation, supporting either **Merge** or **Replace/Overwrite** modes.
- 🌓 **Adaptive Theming**: Built-in support for Light and Dark modes with instant toggling.
- 💾 **Offline & Persistent**: Automatically persists all data locally using `shared_preferences`.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.0.0`)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`)
- **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Utilities**: [intl](https://pub.dev/packages/intl) (dates & formatting), [uuid](https://pub.dev/packages/uuid) (unique IDs), [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- **Pattern**: Layered Architecture (`models` → `services` → `controllers` → `views`)

### Directory Structure

```text
lib/
├── controllers/      # State management (TodoController)
├── models/           # Data entities (Category, TodoItem, AppData)
├── services/         # Storage and clipboard handling
├── views/            # UI layer
│   ├── categories/   # Category management screens and dialogs
│   ├── import_export/# JSON import/export dialog
│   ├── tasks/        # Active/completed task lists, dialogs, batch actions
│   └── theme/        # Light and dark theme configurations
└── main.dart         # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

1. **Flutter SDK** (v3.0.0 or higher): [Installation Guide](https://docs.flutter.dev/get-started/install)
2. **Dart SDK** (included with Flutter)
3. Platform-specific development tools (depending on your target):
   - **Android**: Android Studio / Android SDK & emulator or device.
   - **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.
   - **Web**: Google Chrome.
   - **iOS / macOS**: Xcode (macOS only).

Verify your environment setup:
```bash
flutter doctor
```

---

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd flutter-todo
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

---

### Running the Application

To launch the application on an active device, emulator, or browser:

```bash
flutter run
```

#### Run on a specific device/platform:

- **Linux desktop**:
  ```bash
  flutter run -d linux
  ```
- **Web (Chrome)**:
  ```bash
  flutter run -d chrome
  ```
- **Android / Connected device**:
  ```bash
  flutter devices            # List available device IDs
  flutter run -d <DEVICE_ID>
  ```
- **Release mode**:
  ```bash
  flutter run --release
  ```

---

### Running Tests & Quality Checks

- **Run all unit & widget tests**:
  ```bash
  flutter test
  ```
- **Run static analysis**:
  ```bash
  flutter analyze
  ```
- **Format code**:
  ```bash
  dart format .
  ```

---

### Building for Production

- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **Android App Bundle (AAB)**:
  ```bash
  flutter build appbundle --release
  ```
- **Linux Desktop**:
  ```bash
  flutter build linux --release
  ```
- **Web Application**:
  ```bash
  flutter build web --release
  ```

---

## 📦 Data Schema (Import / Export)

Exported clipboard data uses the following JSON format:

```json
{
  "schemaVersion": 1,
  "exportedAt": "2026-09-01T12:00:00.000Z",
  "categories": [
    {
      "id": "uuid-v4",
      "name": "Work",
      "colorValue": 4280391411,
      "iconCodePoint": 58136,
      "orderIndex": 0
    }
  ],
  "todos": [
    {
      "id": "uuid-v4",
      "categoryId": "uuid-v4",
      "title": "Complete documentation",
      "description": "Add installation and execution steps",
      "dueDate": "2026-09-05T00:00:00.000Z",
      "isCompleted": false,
      "orderIndex": 0,
      "createdAt": "2026-09-01T10:00:00.000Z",
      "completedAt": null
    }
  ]
}
```

---

## 📄 License

This project is open source and available under the standard MIT License (or project terms).
