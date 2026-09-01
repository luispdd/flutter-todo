## Purpose

Provides task management within categories, supporting active/completed states, batch operations, and drag-and-drop ordering.

## ADDED Requirements

### Requirement: Active Task Management & Drag-and-Drop Sorting
The system SHALL provide an active task list per category supporting CRUD operations and manual drag-and-drop reordering.

#### Scenario: Adding and reordering active tasks
- **GIVEN** an active category
- **WHEN** a task is added with title, optional description, and optional due date
- **THEN** the task is assigned to that category with isCompleted = false and placed at the top or end of the active list.
- **WHEN** a user drags an active task to a new index
- **THEN** the list reorders immediately and the new sequence order is persisted.

### Requirement: Active Task Multi-Selection & Batch Actions
The system SHALL support selecting multiple active tasks and performing batch operations.

#### Scenario: Batch completing or deleting active tasks
- **WHEN** a user selects one or more active tasks
- **THEN** the contextual action bar displays the count of selected items.
- **WHEN** the user triggers "Complete Selected"
- **THEN** all selected tasks SHALL have isCompleted set to true, record completedAt timestamp, and move to the completed list.
- **WHEN** the user triggers "Delete Selected"
- **THEN** all selected tasks SHALL be removed from the system.

### Requirement: Completed Tasks Partition & Navigation
The system SHALL provide a dedicated Completed Tasks view accessible directly from the category task screen.

#### Scenario: Viewing completed tasks
- **GIVEN** a category with completed tasks
- **WHEN** the user navigates to the Completed Tasks view
- **THEN** all completed tasks for that category SHALL be displayed in their custom sort order.

### Requirement: Completed Tasks Reordering & Batch Restoration / Permanent Deletion
The system SHALL allow completed tasks to be reordered, edited, restored to active, or permanently deleted individually or in bulk.

#### Scenario: Restoring or deleting completed tasks
- **WHEN** a user drags a completed task
- **THEN** the completed list order updates and persists.
- **WHEN** a user selects "Restore / Send back to active" (single or batch)
- **THEN** the selected tasks SHALL have isCompleted set to false, completedAt reset to null, and move back to the active tasks list.
- **WHEN** a user selects "Delete Permanently" (single or batch)
- **THEN** the selected completed tasks SHALL be removed from storage.
