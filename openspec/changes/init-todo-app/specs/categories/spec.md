# Categories Specification

## ADDED Requirements

### Requirement: Category Creation & Customization
The system SHALL allow users to create categories with a unique title, color theme, and icon representation.
- `GIVEN` a user provides a non-empty name, a color value, and an icon code point
- `WHEN` the category is saved
- `THEN` the category is assigned a unique identifier, saved to persistent storage, and rendered in the category list.

### Requirement: Category Deletion & Cascade
The system SHALL allow users to delete an existing category.
- `GIVEN` an existing category with associated active or completed tasks
- `WHEN` the user confirms deletion of the category
- `THEN` the category and all associated tasks SHALL be permanently removed from storage.

### Requirement: Category Reordering
The system SHALL allow users to reorder categories to reflect custom priority.
- `WHEN` a user drags a category to a new position
- `THEN` the system SHALL persist the updated order index across restarts and exports.
