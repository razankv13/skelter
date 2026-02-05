---
name: create-bloc
description: Create BLoC + Event + State files for a feature
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Create BLoC

Creates a BLoC trio (BLoC, Event, State) for an existing feature or
as a secondary BLoC within a feature directory.

**Usage:** `/create-bloc FeatureName`

The argument is PascalCase (e.g., `ProductReview`). Files are created
in `lib/presentation/{feature_name}/bloc/`.

## Naming Conventions

Given input `FeatureName`:
- **BLoC:** `{FeatureName}Bloc`
- **Event base:** `{FeatureName}Event`
- **State:** `{FeatureName}State`
- **Files:** `{feature_name}_bloc.dart`, `{feature_name}_event.dart`,
  `{feature_name}_state.dart`

## Steps

### 1. Parse the feature name

Extract `FeatureName` from the user argument. Derive
`feature_name` (snake_case).

### 2. Verify feature directory exists

Check that `lib/presentation/{feature_name}/` exists. If not, ask
the user whether to create it or if the feature name is wrong.

### 3. Create bloc directory

Create `lib/presentation/{feature_name}/bloc/` if it doesn't exist.

### 4. Create {feature_name}_state.dart

Follow the exact pattern from
`lib/presentation/product_detail/bloc/product_detail_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class {FeatureName}State with EquatableMixin {
  final bool isLoading;
  final String? errorMessage;

  const {FeatureName}State({
    required this.isLoading,
    this.errorMessage,
  });

  const {FeatureName}State.initial()
      : isLoading = false,
        errorMessage = null;

  {FeatureName}State.copy({FeatureName}State state)
      : isLoading = state.isLoading,
        errorMessage = state.errorMessage;

  {FeatureName}State copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return {FeatureName}State(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @visibleForTesting
  const {FeatureName}State.test({
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class {FeatureName}LoadingState
    extends {FeatureName}State {
  {FeatureName}LoadingState({FeatureName}State state)
      : super.copy(state.copyWith(isLoading: true));
}

class {FeatureName}LoadedState
    extends {FeatureName}State {
  {FeatureName}LoadedState({FeatureName}State state)
      : super.copy(state.copyWith(isLoading: false));
}

class {FeatureName}ErrorState
    extends {FeatureName}State {
  {FeatureName}ErrorState(
    {FeatureName}State state, {
    required String errorMessage,
  }) : super.copy(
          state.copyWith(errorMessage: errorMessage),
        );
}
```

**Key patterns:**
- `EquatableMixin` (not extends Equatable)
- `.initial()` constructor with defaults
- `.copy()` constructor that copies all fields from another state
- `.copyWith()` method for partial updates
- `@visibleForTesting .test()` constructor with optional params
- Sub-states use `super.copy(state.copyWith(...))` pattern

### 5. Create {feature_name}_event.dart

Follow the exact pattern from
`lib/presentation/product_detail/bloc/product_detail_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class {FeatureName}Event with EquatableMixin {
  const {FeatureName}Event();
}

class Fetch{FeatureName}DataEvent
    extends {FeatureName}Event {
  const Fetch{FeatureName}DataEvent();

  @override
  List<Object?> get props => [];
}
```

**Key patterns:**
- `abstract class` with `EquatableMixin`
- `const` constructor
- Each event has its own `props` override

### 6. Create {feature_name}_bloc.dart

Follow the exact pattern from
`lib/presentation/product_detail/bloc/product_detail_bloc.dart`:

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';

class {FeatureName}Bloc
    extends Bloc<{FeatureName}Event, {FeatureName}State> {
  {FeatureName}Bloc()
      : super(const {FeatureName}State.initial()) {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    on<Fetch{FeatureName}DataEvent>(
      _onFetch{FeatureName}DataEvent,
      transformer: droppable(),
    );
  }

  void _onFetch{FeatureName}DataEvent(
    Fetch{FeatureName}DataEvent event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit({FeatureName}LoadingState(state));

    // TODO: Add use case call and result.fold()
    emit({FeatureName}LoadedState(state));
  }
}
```

**Key patterns:**
- `_setupEventListeners()` method for all `on<>()` calls
- Handler methods prefixed with `_on`
- Emit loading state, await use case, `result.fold()` pattern
- Constructor injects use cases as named required params
- Use cases stored as private `final` fields
- Use `droppable()` transformer for fetch events (prevents
  duplicate API calls from rapid taps)

---

### Event Transformer Reference

Apply transformers in `_setupEventListeners()` based on event type:

| Event Type | Transformer | Reason |
|------------|-------------|--------|
| Fetch/load data | `droppable()` | Ignores duplicate taps while fetch in progress |
| Search/filter | `restartable()` | Cancels in-progress handler when new input arrives |
| Form input | none (default) | Default concurrent is fine |
| Navigation | `droppable()` | Prevents double-tap navigation |

```dart
// Search example with restartable:
on<Search{FeatureName}Event>(
  _onSearch{FeatureName}Event,
  transformer: restartable(),
);
```

Requires `bloc_concurrency` package. If a BLoC has no async
events, omit transformers entirely

### 7. Post-creation message

After creating all files, remind the user to:

1. Add use case dependencies to the BLoC constructor
2. Update the event and state classes with feature-specific
   fields and sub-states
3. Implement the `result.fold()` pattern in event handlers
4. Add `droppable()` or `restartable()` transformers to event
   handlers that call async operations
5. If `bloc_concurrency` is not in pubspec.yaml, add it:
   `fvm flutter pub add bloc_concurrency`

**Anti-patterns to avoid:**
- NEVER create BLoC inside a `build()` method — always use
  `BlocProvider(create: ...)` to manage lifecycle
- NEVER inject other BLoCs into this BLoC — use `BlocListener`
  in UI or a shared repository for Bloc-to-Bloc communication

## Linting Rules to Enforce

- Use `package:skelter/...` imports only (no relative imports)
- Single quotes for all strings
- Trailing commas on all argument lists
- `const` constructors where possible
- `final` local variables
- Lines under 80 characters
- No positional boolean parameters
- Named parameters for constructor arguments
