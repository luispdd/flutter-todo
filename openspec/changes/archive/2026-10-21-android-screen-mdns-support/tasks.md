## 1. Dependencies and Android Configuration

- [x] 1.1 Add `multicast_dns` dependency to `pubspec.yaml` and verify `flutter pub get` succeeds without version conflicts.
- [x] 1.2 Update `android/app/src/main/AndroidManifest.xml` to enable `android:usesCleartextTraffic="true"` and declare `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, and `CHANGE_WIFI_MULTICAST_STATE` permissions.

## 2. Multicast DNS Resolver Service

- [x] 2.1 Create `MdnsResolver` in `lib/services/mdns_resolver.dart` with IPv4 A-record discovery, Android multicast lock acquisition/release, and a configurable 3-second timeout.
- [x] 2.2 Implement in-memory IP caching and cache eviction logic on failure within `MdnsResolver`, verified by unit tests in `test/services/mdns_resolver_test.dart`.

## 3. ScreenApiService Integration

- [x] 3.1 Update `ScreenApiService` in `lib/services/screen_api_service.dart` to inject `MdnsResolver` and translate `.local` hostnames to resolved IP addresses before issuing HTTP requests.
- [x] 3.2 Update and expand `test/services/screen_api_service_test.dart` with tests for mDNS resolution, cached IP reuse, and friendly error reporting on discovery timeouts.

## 4. Verification and Build Validation

- [x] 4.1 Run `flutter test` to verify all unit and widget tests pass cleanly.
- [x] 4.2 Verify release compilation for both target platforms using `flutter build apk --release` and `flutter build linux --release`.
