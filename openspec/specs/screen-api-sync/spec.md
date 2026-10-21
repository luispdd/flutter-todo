# screen-api-sync Specification

## Purpose
Provides two-way task synchronization between category tasks and the Waveshare ESP32-S3 To-Do appliance REST API at http://screen.local.

## Requirements

### Requirement: Screen Appliance Push Synchronization
The system SHALL provide a "Push to API" operation that replaces all tasks on the ESP32 To-Do appliance with the active (pending) tasks of the current category.

#### Scenario: Successful push to appliance
- **GIVEN** a category with API sync enabled and one or more active tasks
- **WHEN** the user triggers "Push to API"
- **THEN** the system SHALL fetch existing tasks via `GET /tasks` from `http://screen.local`, invoke `DELETE /tasks/{id}` for each existing task, and send all pending tasks in a JSON array payload via `POST /tasks`.

#### Scenario: Push when no pending tasks exist
- **GIVEN** a category with API sync enabled and zero pending tasks
- **WHEN** the user triggers "Push to API"
- **THEN** the system SHALL delete existing appliance tasks via `DELETE /tasks/{id}` and display confirmation without posting empty task batches.

#### Scenario: Push network or server failure
- **GIVEN** the appliance is unreachable or returns an HTTP error
- **WHEN** the user triggers "Push to API"
- **THEN** the system SHALL display a descriptive error notification and preserve all local tasks without data loss.

### Requirement: Screen Appliance Pull Synchronization
The system SHALL provide a "Pull from API" operation that replaces all local tasks in the current category with the tasks retrieved from the ESP32 To-Do appliance.

#### Scenario: Successful pull from appliance
- **GIVEN** a category with API sync enabled
- **WHEN** the user triggers "Pull from API"
- **THEN** the system SHALL clear all current tasks (both active and completed) in the local category, fetch tasks via `GET /tasks` from `http://screen.local`, and create corresponding local tasks preserving their title and completed state (`done`).

#### Scenario: Pull network or server failure
- **GIVEN** the appliance is unreachable or returns an HTTP error
- **WHEN** the user triggers "Pull from API"
- **THEN** the system SHALL display an error message and avoid modifying existing local tasks.

### Requirement: Category Screen Sync Action Controls
The system SHALL display sync action controls alongside task creation buttons when API sync is active for the current category.

#### Scenario: Sync buttons display for sync-enabled category
- **GIVEN** a category with `isApiSyncEnabled` set to true
- **WHEN** the user views the category task screen in normal mode (not multi-selection mode)
- **THEN** the system SHALL display "Pull from API", "Push to API", and "Add Task" action buttons.

#### Scenario: Sync buttons hidden when disabled
- **GIVEN** a category with `isApiSyncEnabled` set to false
- **WHEN** the user views the category task screen
- **THEN** the system SHALL display only the standard "Add Task" button.

### Requirement: Appliance Host Resolution via Multicast DNS
The system SHALL resolve `.local` appliance hostnames (such as `screen.local`) dynamically via Multicast DNS (mDNS) when communicating with the screen appliance, allowing seamless connection across platforms including Android where standard DNS resolvers lack native `.local` resolution.

#### Scenario: Successful mDNS resolution and request
- **GIVEN** the appliance base URL is configured with a `.local` hostname and the device is connected to local Wi-Fi
- **WHEN** the system initiates a push or pull sync operation
- **THEN** the system SHALL discover the appliance's IPv4 address via mDNS query, cache the resolved address in memory, and execute HTTP requests against the resolved IP address over cleartext HTTP.

#### Scenario: Reusing cached mDNS address
- **GIVEN** a previously resolved and cached IP address for the appliance
- **WHEN** a subsequent sync request (such as task deletion or creation) is executed
- **THEN** the system SHALL reuse the cached IP address without repeating the multicast discovery query.

#### Scenario: mDNS discovery timeout or unreachable appliance
- **GIVEN** the appliance is not powered on or cannot be discovered on the local network within the discovery timeout
- **WHEN** the user initiates a sync operation
- **THEN** the system SHALL terminate the discovery attempt and display a descriptive error notification indicating that the screen appliance could not be found on the local network.

#### Scenario: Invalidation of stale cached address
- **GIVEN** a cached IP address that no longer responds to HTTP requests
- **WHEN** an HTTP operation against the cached address fails with a connection error
- **THEN** the system SHALL clear the cached address so that subsequent operations trigger a fresh mDNS discovery cycle.

