# tasks Specification

## Purpose
Provides task management within categories, supporting active/completed states, checkbox selection, dedicated edit triggers, bottom action bars, and drag-and-drop ordering.

## Requirements

### Requirement: Active Task Management & Drag-and-Drop Sorting
The system SHALL provide an active task list per category supporting CRUD operations, checkbox-based selection, and manual drag-and-drop reordering.

#### Scenario: Adding and reordering active tasks
- **GIVEN** an active category
- **WHEN** a task is added with title, optional description, and optional due date
- **THEN** the task is assigned to that category with isCompleted = false and placed at the top or end of the active list.
- **WHEN** a user drags an active task to a new index
- **THEN** the list reorders immediately and the new sequence order is persisted.

### Requirement: Task Selection via Checkbox & Item Body
The system SHALL use checkboxes to represent item selection and allow checking/unchecking by tapping the checkbox or the task body.

#### Scenario: Tapping checkbox or item body
- **GIVEN** an active or completed task item in a category
- **WHEN** a user taps the checkbox OR taps anywhere on the item body
- **THEN** the task selection state SHALL toggle (selected/unselected) without immediately moving the task to another list.

### Requirement: Dedicated Edit Button Trigger
The system SHALL only open the task edit dialog when the user explicitly clicks the Edit action button.

#### Scenario: Editing task details
- **WHEN** a user taps the Edit icon button on an item
- **THEN** the system SHALL open the `TaskDialog` pre-filled with the task's title, description, category, and due date.

### Requirement: Bottom Action Bars for Batch Operations
The system SHALL display a bottom action bar whenever one or more items are selected.

#### Scenario: Completing active tasks via bottom bar
- **WHEN** one or more active tasks are selected
- **THEN** a bottom action bar SHALL display a "Complete" button that completes all selected tasks upon click.

#### Scenario: Reactivating or deleting completed tasks via bottom bar
- **WHEN** one or more completed tasks are selected
- **THEN** a bottom action bar SHALL display two buttons: "Reactivate" (restores selected tasks to active) and "Permanently Delete" (deletes selected tasks permanently).

### Requirement: Completed Tasks Partition & Navigation
The system SHALL provide a dedicated Completed Tasks view accessible directly from the category task screen.

#### Scenario: Viewing completed tasks
- **GIVEN** a category with completed tasks
- **WHEN** the user navigates to the Completed Tasks view
- **THEN** all completed tasks for that category SHALL be displayed in their custom sort order.
