## ADDED Requirements

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
