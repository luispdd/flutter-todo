# categories Specification

## Purpose
Provides category management for organizing tasks with custom colors, icons, and display ordering.

## Requirements

### Requirement: Category Creation & Customization
The system SHALL allow users to create categories with a unique title, color theme, and icon representation.

#### Scenario: Successful category creation
- **GIVEN** a user provides a non-empty name, a color value, and an icon code point
- **WHEN** the category is saved
- **THEN** the category is assigned a unique identifier, saved to persistent storage, and rendered in the category list.

### Requirement: Category Deletion & Cascade
The system SHALL allow users to delete an existing category.

#### Scenario: Cascade deletion of category with tasks
- **GIVEN** an existing category with associated active or completed tasks
- **WHEN** the user confirms deletion of the category
- **THEN** the category and all associated tasks SHALL be permanently removed from storage.

### Requirement: Category Reordering
The system SHALL allow users to reorder categories to reflect custom priority.

#### Scenario: Reorder categories via drag and drop
- **WHEN** a user drags a category to a new position
- **THEN** the system SHALL persist the updated order index across restarts and exports.

### Requirement: Category API Sync Configuration
The system SHALL allow users to enable or disable external API synchronization for individual categories.

#### Scenario: Enabling API sync in category dialog
- **GIVEN** a user editing or creating a category
- **WHEN** the user toggles the "Activate API sync" option to on and saves
- **THEN** the category's `isApiSyncEnabled` property SHALL be persisted as true and reflected across sessions.

### Requirement: Last Active Category Screen Restoration
The system SHALL record the active category screen and restore it when the application launches.

#### Scenario: Restoring last active category on startup
- **GIVEN** a user was viewing a category's task screen when the application was closed or backgrounded
- **WHEN** the application is reopened
- **THEN** the system SHALL automatically navigate to that category's task screen, keeping the categories overview accessible in the navigation backstack.

#### Scenario: Navigating back to category overview
- **GIVEN** the application was restored directly to a category's task screen
- **WHEN** the user presses back or returns to the category overview
- **THEN** the system SHALL display the categories screen and clear the saved active category reference.

#### Scenario: Category was deleted before restart
- **GIVEN** the stored category ID does not match any existing category on launch
- **WHEN** the application opens
- **THEN** the system SHALL fall back to displaying the standard categories screen without error.
