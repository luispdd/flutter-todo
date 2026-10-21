## Why

When running the application on Linux, requests to the ESP32 To-Do appliance at `http://screen.local` resolve seamlessly via system mDNS (Avahi/systemd-resolved). However, on Android, requests fail with `SocketException: OS Error: No address associated with hostname, errno = 7` because Android's standard DNS resolver queries unicast DNS servers rather than resolving `.local` domains via Multicast DNS. Furthermore, Android 9+ blocks cleartext HTTP by default unless specifically permitted.

Adding in-app mDNS discovery and configuring Android network permissions enables Android devices to discover and synchronize with the ESP32 screen appliance seamlessly.

## What Changes

- **Automatic mDNS Host Resolution**: Introduce an mDNS resolution helper (using `multicast_dns` and Android multicast lock handling) within `ScreenApiService` to resolve `.local` hostnames to their LAN IPv4 addresses before executing HTTP requests.
- **Resolved IP Caching**: Cache the discovered IP address in memory to avoid repetitive multicast queries for consecutive requests, with automatic cache invalidation on network connection changes or failures.
- **Android Cleartext and Permissions**:
  - Add `android:usesCleartextTraffic="true"` to `AndroidManifest.xml` to permit HTTP communication with local IoT devices.
  - Add required permissions: `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, and `CHANGE_WIFI_MULTICAST_STATE`.
- **Informative Error Handling**: Provide clear error messages if mDNS discovery fails or times out, informing the user to check local Wi-Fi connectivity and multicast/AP isolation settings.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `screen-api-sync`: Expand the appliance connection requirements to support in-app Multicast DNS (mDNS) resolution for `.local` hostnames and cleartext HTTP communication on Android.

## Impact

- **Services**: `lib/services/screen_api_service.dart` will incorporate mDNS resolution before delegating to `http.Client`.
- **Platform Configuration**: `android/app/src/main/AndroidManifest.xml` updated with cleartext traffic flag and Wi-Fi multicast permissions.
- **Dependencies**: Add `multicast_dns` and a multicast lock mechanism in `pubspec.yaml`.
- **Compatibility**: Android devices on local Wi-Fi will now be able to discover and communicate with `http://screen.local` alongside existing Linux desktop support.
