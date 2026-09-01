# Import / Export Specification

## ADDED Requirements

### Requirement: Clipboard JSON Export
The system SHALL serialize the entire application state into structured JSON and copy it to the system clipboard upon user request.
- `GIVEN` existing categories and tasks in the application
- `WHEN` the user triggers "Export to Clipboard"
- `THEN` the system SHALL format the data according to the `AppData` schema (including `schemaVersion`, `exportedAt`, `categories`, and `todos`) and write it to the clipboard.

### Requirement: Clipboard JSON Import & Validation
The system SHALL allow users to paste JSON from the clipboard and validate its structure prior to ingestion.
- `GIVEN` a JSON string in the clipboard or input field
- `WHEN` the user initiates import
- `THEN` the system SHALL validate the JSON syntax and verify required fields (`categories`, `todos`).
- `IF` validation fails, `THEN` an explanatory error message SHALL be displayed without modifying existing data.
- `IF` validation passes, `THEN` the user SHALL be given the choice to "Replace All" or "Merge with Existing".
