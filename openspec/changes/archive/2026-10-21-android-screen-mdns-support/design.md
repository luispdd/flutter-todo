## Context

See `proposal.md` for problem background and requirements. The application connects to a standalone Waveshare ESP32 To-Do appliance over local Wi-Fi. While Linux desktop resolves `http://screen.local` natively via system mDNS (Avahi/systemd-resolved), Android's standard DNS resolver throws `SocketException: OS Error: No address associated with hostname, errno = 7` when querying unicast DNS servers. In addition, Android 9+ requires explicit configuration to permit cleartext `http://` traffic.

## Goals / Non-Goals

**Goals:**
- Automatically resolve `.local` hostnames (specifically `screen.local`) to LAN IPv4 addresses using in-app mDNS discovery.
- Cache resolved IP addresses in memory to keep HTTP sync operations fast and prevent repetitive multicast traffic.
- Enable cleartext HTTP traffic and Wi-Fi multicast permissions on Android.
- Ensure existing Linux and unit test behavior remains unaffected.

**Non-Goals:**
- External internet / WAN synchronization or cloud relay (communication remains strictly on local Wi-Fi).
- Bluetooth LE or USB serial pairing.

## Decisions

### 1. Dedicated `MdnsResolver` Service
- **Decision**: Create a dedicated `MdnsResolver` in `lib/services/mdns_resolver.dart` utilizing `multicast_dns` to query IPv4 A-records for `.local` hostnames.
- **Rationale**: Isolates multicast socket logic and platform channel interactions from HTTP REST client concerns, enabling straightforward unit testing and mocking.
- **Alternatives Considered**:
  - *Hardcoding or asking user for IP address*: Rejected as Option 2 was selected for automated, zero-configuration discovery.
  - *Using `nsd` plugin*: `nsd` searches for DNS-SD service instances (`_http._tcp.local`), whereas ESP32 mDNS frequently only registers the basic A-record hostname (`screen.local`). `multicast_dns` can directly query for the A record.

### 2. Transparent URI Translation with In-Memory Caching in `ScreenApiService`
- **Decision**: In `ScreenApiService`, inspect outgoing requests. If the hostname ends with `.local`, resolve it via `MdnsResolver` before creating the final HTTP `Uri`:
  ```dart
  Uri resolveUri(Uri uri) {
    if (uri.host.endsWith('.local')) {
      final ip = await _resolver.resolveHost(uri.host);
      return uri.replace(host: ip);
    }
    return uri;
  }
  ```
- **Rationale**: Keeps the external API of `ScreenApiService` clean and backwards-compatible with `http://screen.local`.
- **Cache Invalidation**: The resolved IP is cached until an HTTP request fails with a network exception (`SocketException` / timeout), at which point the cache is evicted to force fresh discovery.

### 3. Android Platform Permissions & Cleartext Configuration
- **Decision**: Update `android/app/src/main/AndroidManifest.xml` with:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
  ```
  and `android:usesCleartextTraffic="true"` on the `<application>` tag.
- **Rationale**: Required by Android to allow cleartext HTTP (API 28+) and receive UDP multicast traffic.

## Risks / Trade-offs

- **[Risk] Wi-Fi Access Point blocks multicast (AP Isolation)** &rarr; *Mitigation*: Cap mDNS discovery at a 3-second timeout. If no response is received, surface an informative error message explaining that the device was not found on the local Wi-Fi network and suggesting checking AP isolation.
- **[Risk] Android battery optimization dropping multicast packets** &rarr; *Mitigation*: Acquire Android's `WifiManager.MulticastLock` before starting discovery and release it promptly upon receiving the response or timing out.
- **[Risk] Running in Android Emulator** &rarr; *Mitigation*: Android emulators use private NAT (`10.0.2.x`) which cannot receive physical Wi-Fi multicast broadcasts from the host LAN. Document that testing appliance sync on Android requires a physical device on the same Wi-Fi network.
