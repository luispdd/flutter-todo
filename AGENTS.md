# Operational Guidelines

## Android Build Gotchas
- **Kotlin DSL Precedence**: The project uses Gradle Kotlin DSL (`.gradle.kts`). Do not keep or add Groovy `.gradle` files (`settings.gradle`, `build.gradle`, `app/build.gradle`) alongside `.gradle.kts`; Gradle will prioritize Groovy and fail on deprecated imperative plugin loading (`app_plugin_loader.gradle`).

## Build & Verification Commands
- `flutter test`: Run unit and widget tests.
- `flutter build apk --release`: Build release Android APK.
- `flutter build linux --release`: Build release Linux binary.
