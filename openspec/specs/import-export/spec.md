# import-export Specification

## Purpose
Allows full application state backup, transfer, and restoration via JSON data on the clipboard.

## Requirements

### Requirement: Clipboard JSON Export
The system SHALL serialize the entire application state into structured JSON and copy it to the system clipboard upon user request.

#### Scenario: Successful clipboard export
- **GIVEN** existing categories and tasks in the application
- **WHEN** the user triggers "Export to Clipboard"
- **THEN** the system SHALL format the data according to the AppData schema (including schemaVersion, exportedAt, categories, and todos) and write it to the clipboard.

### Requirement: Clipboard JSON Import & Validation
The system SHALL allow users to paste JSON from the clipboard and validate its structure prior to ingestion.

#### Scenario: Invalid JSON data
- **GIVEN** an invalid JSON string or non-matching schema payload in the clipboard or input field
- **WHEN** the user initiates import
- **THEN** an explanatory error message SHALL be displayed without modifying existing data.

#### Scenario: Valid JSON data import choice
- **GIVEN** valid AppData JSON structure
- **WHEN** the user confirms import
- **THEN** the system SHALL provide choices to "Replace All" or "Merge with Existing" data and persist the changes.
