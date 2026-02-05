---
name: create-test
description: Generate test files for a feature (BLoC, widget, golden)
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Create Test

Creates test files following Skelter's existing test patterns.

**Usage:**
- `/create-test feature_name --bloc` — BLoC unit tests
- `/create-test feature_name --widget` — Widget tests
- `/create-test feature_name --golden` — Golden (screenshot) tests
- `/create-test feature_name --bloc --widget --golden` — All types

The argument is snake_case feature name. At least one flag
is required.

## Steps

### 1. Parse arguments

Extract:
- `feature_name` (snake_case)
- `FeatureName` (PascalCase derived)
- Flags: `--bloc`, `--widget`, `--golden`

### 2. Verify feature exists

Check that `lib/presentation/{feature_name}/` exists. If not,
ask the user for the correct feature name.

### 3. Read the feature's BLoC, state, and event files

Read the actual BLoC, State, and Event files for this feature to
understand the specific events, states, and dependencies needed
for accurate test generation.

---

## BLoC Test (`--bloc`)

**File:** `test/presentation/{feature_name}/bloc/{feature_name}_bloc_test.dart`

Follow pattern from
`test/presentation/login/bloc/login_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/domain/usecases/get_{feature_name}s.dart';

class MockGet{FeatureName}s extends Mock
    implements Get{FeatureName}s {}

void main() {
  late MockGet{FeatureName}s mockGet{FeatureName}s;

  setUp(() {
    mockGet{FeatureName}s = MockGet{FeatureName}s();
  });

  group('{FeatureName}Bloc Initialization', () {
    blocTest<{FeatureName}Bloc, {FeatureName}State>(
      'should emit initial state with defaults',
      build: () => {FeatureName}Bloc(
        get{FeatureName}s: mockGet{FeatureName}s,
      ),
      expect: () => <{FeatureName}State>[],
      verify: (bloc) {
        expect(
          bloc.state,
          const {FeatureName}State.initial(),
        );
      },
    );
  });

  group('{FeatureName}Bloc Data Fetching', () {
    blocTest<{FeatureName}Bloc, {FeatureName}State>(
      'should emit Loading then Loaded on success',
      build: () {
        when(() => mockGet{FeatureName}s())
            .thenAnswer(
          (_) async => const Right([]),
        );
        return {FeatureName}Bloc(
          get{FeatureName}s: mockGet{FeatureName}s,
        );
      },
      act: (bloc) => bloc.add(
        const Get{FeatureName}DataEvent(),
      ),
      expect: () => [
        isA<{FeatureName}LoadingState>(),
        isA<{FeatureName}LoadedState>().having(
          (s) => s.items,
          'items',
          isEmpty,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGet{FeatureName}s(),
        ).called(1);
      },
    );

    blocTest<{FeatureName}Bloc, {FeatureName}State>(
      'should emit Loading then Error on failure',
      build: () {
        when(() => mockGet{FeatureName}s())
            .thenAnswer(
          (_) async => const Left(
            APIFailure(
              message: 'Server error',
              statusCode: 500,
            ),
          ),
        );
        return {FeatureName}Bloc(
          get{FeatureName}s: mockGet{FeatureName}s,
        );
      },
      act: (bloc) => bloc.add(
        const Get{FeatureName}DataEvent(),
      ),
      expect: () => [
        isA<{FeatureName}LoadingState>(),
        isA<{FeatureName}ErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Server error',
        ),
      ],
      verify: (_) {
        verify(
          () => mockGet{FeatureName}s(),
        ).called(1);
      },
    );
  });
}
```

**Key patterns:**
- `blocTest<Bloc, State>()` with `build`, `act`, `expect`
- Mock use cases with `mocktail`
- `when(() => ...).thenAnswer((_) async => Right/Left(...))`
- Group by: Initialization, Data Fetching, Error States
- `setUp()` creates fresh mocks for each test
- `verify` callback to assert use case call count
- `isA<T>().having()` for asserting specific state properties

---

### Advanced BLoC Test Patterns

**`predicate<T>()` matcher** — for checking computed state
properties without specifying the exact state subtype:

```dart
expect: () => [
  predicate<{FeatureName}State>(
    (state) => state.items.length == 3,
  ),
],
```

**Multiple events in `act()`** — test event sequences:

```dart
act: (bloc) {
  bloc.add(const Event1());
  bloc.add(const Event2());
},
```

**`isA<T>().having()` chaining** — multiple assertions on
one state emission:

```dart
isA<{FeatureName}ErrorState>()
    .having(
      (s) => s.errorMessage,
      'errorMessage',
      'Server error',
    )
    .having(
      (s) => s.items,
      'items',
      isEmpty,
    ),
```

**`seed` parameter** — start from a non-initial state (use
when testing events that depend on prior state):

```dart
blocTest<{FeatureName}Bloc, {FeatureName}State>(
  'should filter loaded items',
  seed: () => {FeatureName}State.test(
    items: testItems,
  ),
  build: () => {FeatureName}Bloc(...),
  act: (bloc) => bloc.add(FilterEvent('query')),
  ...
);
```

**`wait` parameter** — for debounced/delayed events:

```dart
blocTest<{FeatureName}Bloc, {FeatureName}State>(
  'should emit results after debounce',
  build: () => {FeatureName}Bloc(...),
  act: (bloc) => bloc.add(SearchEvent('query')),
  wait: const Duration(milliseconds: 350),
  ...
);
```

Do NOT use `seed`, `wait`, or `skip` by default. Only add
them when the test scenario requires non-initial state,
debounced events, or skipping intermediate states

---

## Widget Test (`--widget`)

**File:** `test/presentation/{feature_name}/{feature_name}_screen_test.dart`

**Tag:** Add `@Tags(['widgetTest'])` at the top of the file.

Follow pattern from
`test/presentation/home/home_screen_test.dart`:

```dart
@Tags(['widgetTest'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/screens/{feature_name}_screen.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class Mock{FeatureName}Bloc
    extends MockBloc<{FeatureName}Event, {FeatureName}State>
    implements {FeatureName}Bloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'tenantIdTest',
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
  });

  group('{FeatureName} Screen', () {
    testWidgets(
      '{feature_name} screen renders',
      (tester) async {
        // arrange
        final bloc = Mock{FeatureName}Bloc();
        when(() => bloc.state).thenReturn(
          const {FeatureName}State.test(),
        );

        // act
        await tester.runWidgetTest(
          providers: [
            BlocProvider<{FeatureName}Bloc>.value(
              value: bloc,
            ),
          ],
          child: const {FeatureName}Screen(),
        );

        // assert
        expect(
          find.byType({FeatureName}Screen),
          findsOneWidget,
        );
      },
    );
  });
}
```

**Key patterns:**
- `MockBloc` from `bloc_test` + `mocktail`
- `setupFirebaseCoreMocks()` + `Firebase.initializeApp()`
- `tester.runWidgetTest()` helper from `test/test_helpers.dart`
- `BlocProvider.value()` for injecting mock bloc
- `@Tags(['widgetTest'])` at file top

---

## Golden Test (`--golden`)

**File:** `test/presentation/{feature_name}/{feature_name}_golden_test.dart`

**Tag:** Add `@Tags(['golden'])` at the top of the file.

Follow pattern from
`test/presentation/home/home_screen_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/screens/{feature_name}_screen.dart';
import 'package:skelter/widgets/styling/app_theme_data.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class Mock{FeatureName}Bloc
    extends MockBloc<{FeatureName}Event, {FeatureName}State>
    implements {FeatureName}Bloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'tenantIdTest',
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
  });

  group('{FeatureName} Golden Tests', () {
    testExecutable(() {
      goldenTest(
        '{FeatureName} screen UI test',
        fileName: '{feature_name}_screen',
        pumpBeforeTest: precacheImages,
        builder: () {
          // arrange
          final bloc = Mock{FeatureName}Bloc();
          when(() => bloc.state).thenReturn(
            const {FeatureName}State.test(),
          );

          // act, assert
          return GoldenTestGroup(
            columnWidthBuilder: (_) =>
                const FixedColumnWidth(
              pixel5DeviceWidth,
            ),
            children: [
              createTestScenario(
                name:
                    '{feature_name}_screen Light Theme',
                providers: [
                  BlocProvider<{FeatureName}Bloc>.value(
                    value: bloc,
                  ),
                ],
                child: const {FeatureName}Screen(),
              ),
              createTestScenario(
                name:
                    '{feature_name}_screen Dark Theme',
                providers: [
                  BlocProvider<{FeatureName}Bloc>.value(
                    value: bloc,
                  ),
                ],
                child: const {FeatureName}Screen(),
                theme: AppThemeEnum.DarkTheme,
              ),
            ],
          );
        },
      );
    });
  });
}
```

**Key patterns:**
- `goldenTest()` from `alchemist` package
- `GoldenTestGroup` with `columnWidthBuilder`
- `createTestScenario()` from `test/test_helpers.dart`
- Light + Dark theme variants
- `pumpBeforeTest: precacheImages`
- `pixel5DeviceWidth` from `flutter_test_config.dart`
- `@Tags(['golden'])` at file top

---

## Post-creation

### 4. Create test directories

Ensure `test/presentation/{feature_name}/bloc/` exists for BLoC
tests and `test/presentation/{feature_name}/` for widget/golden.

### 5. Post-creation message

After creating files, remind the user to:

1. Customize mock setup for feature-specific dependencies
2. Add assertions for feature-specific state properties
3. Run tests:
   - BLoC: `fvm flutter test test/presentation/{feature_name}/bloc/`
   - Widget: `fvm flutter test --tags widgetTest test/presentation/{feature_name}/`
   - Golden: `fvm flutter test --tags golden test/presentation/{feature_name}/`
4. Update golden files: `fvm flutter test --update-goldens`

## Linting Rules to Enforce

- Use `package:skelter/...` imports only (no relative imports)
- Single quotes for all strings
- Trailing commas on all argument lists
- `const` constructors where possible
- `final` local variables
- Lines under 80 characters
- No positional boolean parameters
