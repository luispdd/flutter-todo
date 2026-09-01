# Proposal: Initial Flutter To-Do Application (`init-todo-app`)

## Problem Statement
Users need a focused, responsive, and cross-platform task organizer on **Android** and **Linux** that supports structured category partitioning, intuitive drag-and-drop prioritization, multi-item batch workflows, and zero-friction data portability via simple clipboard copy/paste.

## Proposed Solution
Create a new Flutter application targeting Android and Linux with the following capabilities:
1. **Category Management**: Create, edit, reorder, and delete categories with distinct colors and icons.
2. **Active Task Management**: Reorderable drag-and-drop task list per category, task editing, due dates, notes, and individual/multi-select completion and deletion.
3. **Completed Task Management**: Dedicated completed tasks section accessible from the TODO view with reordering, editing, multi-selection, batch uncomplete (restore to active), and permanent deletion.
4. **Clipboard JSON Sync**: Complete data portability allowing single-click copy to clipboard as structured JSON, and pasting from clipboard with schema validation and "Replace" or "Merge" modes.
5. **Local Persistence**: Offline-first local storage automatically syncing state across app sessions.

## Scope & Boundaries
- **In Scope**:
  - Full CRUD and drag-and-drop sorting for categories and tasks.
  - Multi-select batch operations for both active and completed states.
  - Clipboard JSON import/export with schema error handling.
  - Linux desktop and Android mobile UI optimization.
  - Automated unit test suite covering models, controllers, and services.
- **Out of Scope**:
  - Remote cloud backend / user authentication (strictly local-first with clipboard import/export).
  - Third-party calendar integrations.

## User Value
- Full control over task prioritization with smooth drag & drop.
- Fast batch management when handling multiple tasks at once.
- Seamless backup and device-to-device migration without cloud accounts via standard JSON clipboard copy/paste.
