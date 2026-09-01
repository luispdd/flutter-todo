# Tasks Specification

## MODIFIED Requirements

### Requirement: Task Selection via Checkbox & Item Body
The system SHALL use checkboxes to represent item selection and allow checking/unchecking by tapping the checkbox or the task body.
- `GIVEN` an active or completed task item in a category
- `WHEN` a user taps the checkbox OR taps anywhere on the item body
- `THEN` the task selection state SHALL toggle (selected/unselected) without immediately moving the task to another list.

### Requirement: Dedicated Edit Button Trigger
The system SHALL only open the task edit dialog when the user explicitly clicks the Edit action button.
- `WHEN` a user taps the Edit icon button on an item
- `THEN` the system SHALL open the `TaskDialog` pre-filled with the task's title, description, category, and due date.

### Requirement: Bottom Action Bars for Batch Operations
The system SHALL display a mobile-first bottom action bar at the bottom of the screen whenever one or more items are selected.
- `WHEN` one or more active tasks are selected
- `THEN` the bottom action bar SHALL display a single, full-width "Complete" button that uses all available width to complete all selected tasks upon click (with no delete button available for the active selection).
- `WHEN` one or more completed tasks are selected
- `THEN` the bottom action bar SHALL display two buttons: "Reactivate" (restores selected tasks to active) and "Permanently Delete" (deletes selected tasks permanently).
