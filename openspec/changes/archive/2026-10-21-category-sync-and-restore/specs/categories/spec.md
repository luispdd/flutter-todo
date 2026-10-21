## ADDED Requirements

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
