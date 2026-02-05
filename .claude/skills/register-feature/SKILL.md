---
name: register-feature
description: Wire a feature into DI container and app routes
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Register Feature

Wires a scaffolded feature into the app by registering its
dependencies in GetIt and adding its route to auto_route.

**Usage:** `/register-feature FeatureName`

The argument is PascalCase (e.g., `ProductReview`). The snake_case
directory name is derived automatically.

## Steps

### 1. Parse the feature name

Extract `FeatureName` (PascalCase) and derive `feature_name`
(snake_case).

### 2. Verify feature files exist

Glob for the expected files under
`lib/presentation/{feature_name}/`. Verify these exist:
- `domain/usecases/get_{feature_name}s.dart`
- `domain/repositories/{feature_name}_repository.dart`
- `data/repositories/{feature_name}_repository_impl.dart`
- `data/datasources/{feature_name}_remote_data_source.dart`
- `screens/{feature_name}_screen.dart`

If any are missing, warn the user and ask whether to proceed.

### 3. Add imports to injection_container.dart

Read `lib/core/services/injection_container.dart` and add the
following imports (if not already present), grouped with other
feature imports:

```dart
import 'package:skelter/presentation/{feature_name}/data/datasources/{feature_name}_remote_data_source.dart';
import 'package:skelter/presentation/{feature_name}/data/repositories/{feature_name}_repository_impl.dart';
import 'package:skelter/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart';
import 'package:skelter/presentation/{feature_name}/domain/usecases/get_{feature_name}s.dart';
```

### 4. Add DI registrations

Find the `sl` cascade chain in `configureDependencies()` and add
the feature registrations. Follow the existing pattern — use cases
first, then repository, then data source:

```dart
..registerLazySingleton(
  () => Get{FeatureName}s(sl()),
)
..registerLazySingleton<{FeatureName}Repository>(
  () => {FeatureName}RepositoryImpl(sl()),
)
..registerLazySingleton<{FeatureName}RemoteDatasource>(
  () => {FeatureName}RemoteDataSrcImpl(sl()),
)
```

**Key patterns from existing code:**
- Use cases: `..registerLazySingleton(() => UseCase(sl()))`
- Repositories: `..registerLazySingleton<RepoMixin>(() => RepoImpl(sl()))`
- Data sources: `..registerLazySingleton<DsMixin>(() => DsImpl(sl()))`
- All use `sl()` for dependency resolution
- Add before the `..registerLazySingleton<Dio>` line

### 5. Add route to routes.dart

Read `lib/routes.dart` and add the feature route to the
`routes` list. Follow the existing pattern:

```dart
// {FeatureName}
{FeatureName}Route.page,
```

Add it before the closing `]` of the `routes` list, with a
comment header matching the existing style.

### 6. Run build_runner

Execute code generation to create the route file:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Post-registration message

After completing all steps, output:

1. List of changes made to `injection_container.dart`
2. List of changes made to `routes.dart`
3. Remind user to run
   `fvm flutter pub run build_runner build --delete-conflicting-outputs`
   if step 6 failed or was skipped
4. Suggest running `fvm flutter analyze` to verify

## Linting Rules to Enforce

- Use `package:skelter/...` imports only (no relative imports)
- Single quotes for all strings
- Trailing commas on all argument lists
- Lines under 80 characters
