# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Skelter is a production-grade Flutter boilerplate/starter template by SolGuruz. It provides prebuilt utilities, reusable UI components, clean architecture, and a comprehensive test setup for mobile app development.

- **Flutter:** 3.35.7 (managed via FVM)
- **Dart SDK:** ^3.9.2
- **Build flavors:** `dev`, `stage`, `prod`

## Common Commands

### Setup & Dependencies
```bash
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Run App (with flavor)
```bash
fvm flutter run --flavor dev --dart-define=APP_FLAVOR=DEV
fvm flutter run --flavor stage --dart-define=APP_FLAVOR=STAGE
fvm flutter run --flavor prod --dart-define=APP_FLAVOR=PROD
```

### Build APK
```bash
fvm flutter build apk --flavor dev --dart-define=APP_FLAVOR=DEV
```

### Run All Tests
```bash
fvm flutter test
```

### Run a Single Test File
```bash
fvm flutter test test/presentation/home/home_screen_test.dart
```

### Run Tests by Tag
```bash
fvm flutter test --tags golden
fvm flutter test --tags widgetTest
```

### Update Golden Files
```bash
fvm flutter test --update-goldens
```

### Analyze Code
```bash
fvm flutter analyze
```

### Code Generation (auto_route, flutter_gen, etc.)
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture

### Clean Architecture with BLoC

Each feature under `lib/presentation/` follows this layered structure:

```
presentation/[feature]/
├── bloc/           # BLoC, Events, States (business logic)
├── data/
│   ├── datasources/   # Remote/local data sources (API calls)
│   ├── models/        # Data models (JSON serialization)
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Domain entities (plain objects)
│   ├── repositories/  # Abstract repository contracts
│   └── usecases/      # UseCase classes (single business operation)
├── screens/        # Screen widgets
└── widgets/        # Feature-specific widgets
```

### Key Patterns

- **Result type:** All use cases return `ResultFuture<T>` which is `Future<Either<Failure, T>>` (from `dartz`). Defined in `lib/utils/typedef.dart`.
- **UseCases:** Implemented as mixins — `UseCaseWithParams<Type, Params>` and `UseCaseWithoutParams<Type>` in `lib/core/usecase/usecase.dart`.
- **Error handling:** `APIException` (thrown by data sources) → caught in repository impl → converted to `APIFailure` (returned as `Left`). See `lib/core/errors/`.
- **DI:** `GetIt` service locator via `sl` global instance in `lib/core/services/injection_container.dart`. All repositories, data sources, and use cases registered here.
- **Navigation:** `auto_route` with code generation. Routes defined in `lib/routes.dart`, generated to `lib/routes.gr.dart`.
- **Flavors:** `AppConfig` in `lib/utils/app_flavor_env.dart` reads `APP_FLAVOR` from `--dart-define`. Controls base URL, cert hash, and Clarity project ID via `.env` file.

### Global Services (`lib/services/`)

Services are app-wide singletons: `FirebaseAuthService`, `NotificationService`, `SubscriptionService`, `LocalAuthService`, `RemoteConfigService`, `ThemeService`, `SecureStorageService`.

### App Initialization Flow

`main.dart` → `initializeApp()` (in `initialize_app.dart`) → Firebase init (flavor-specific options from `firebase_options_dev/prod/stage.dart`) → Remote Config → dotenv load → `configureDependencies()` (GetIt setup) → `MainApp` widget.

## Testing

- **Unit/Widget tests:** `test/` directory, uses `mocktail` for mocking and `bloc_test` for BLoC tests
- **Golden tests:** Uses `alchemist` package, tagged with `@Tags(['golden'])`. Config in `test/test_config.dart`
- **Integration tests:** `integration_test/` directory using `patrol`
- **Test tags:** Defined in `dart_test.yaml` — `golden` and `widgetTest`
- **Test helpers:** `test/test_helpers.dart` for common utilities

## Linting Rules

Strict lint configuration via `analysis_options.yaml` extending `package:flutter_lints/flutter.yaml`. Key enforced rules:
- `always_use_package_imports` (no relative imports in lib)
- `prefer_single_quotes`
- `require_trailing_commas`
- `prefer_final_locals` and `prefer_final_fields`
- `prefer_const_constructors`
- `lines_longer_than_80_chars`
- `avoid_positional_boolean_parameters`

Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`) are excluded from analysis.

## Localization

ARB-based i18n configured in `l10n.yaml`. Template file: `lib/i18n/app_en.arb`. Access via `AppLocalizations.of(context)`.

## Environment Configuration

Runtime secrets loaded from `.env` via `flutter_dotenv`. Firebase options are flavor-specific files (`firebase_options_dev.dart`, etc.) decoded from base64 secrets in CI. SSL certificate pinning is configured per flavor via `.env` cert hashes.
