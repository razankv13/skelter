---
name: scaffold-feature
description: Scaffold a complete Clean Architecture feature with all boilerplate files
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Scaffold Feature

Creates the complete Clean Architecture directory structure and all
boilerplate files for a new feature in the Skelter codebase.

**Usage:** `/scaffold-feature FeatureName`

The argument is the PascalCase feature name (e.g., `ProductReview`).
The snake_case directory name is derived automatically
(e.g., `product_review`).

## Naming Conventions

Given input `FeatureName`:
- **Directory:** `lib/presentation/{feature_name}/` (snake_case)
- **Entity:** `{FeatureName}` (PascalCase)
- **Model:** `{FeatureName}Model`
- **DataSource mixin:** `{FeatureName}RemoteDatasource`
- **DataSource impl:** `{FeatureName}RemoteDataSrcImpl`
- **Repository mixin:** `{FeatureName}Repository`
- **Repository impl:** `{FeatureName}RepositoryImpl`
- **UseCase:** `Get{FeatureName}`
- **BLoC:** `{FeatureName}Bloc`
- **Event base:** `{FeatureName}Event`
- **State:** `{FeatureName}State`
- **Screen:** `{FeatureName}Screen`

## Steps

### 1. Parse the feature name

Extract `FeatureName` from the user argument. Derive:
- `feature_name` (snake_case for directories and file names)
- `FeatureName` (PascalCase for class names)

### 2. Create directory structure

```
lib/presentation/{feature_name}/
  bloc/
  data/datasources/
  data/models/
  data/repositories/
  domain/entities/
  domain/repositories/
  domain/usecases/
  screens/
  widgets/
```

### 3. Create domain/entities/{feature_name}.dart

Follow the pattern from
`lib/presentation/home/domain/entities/product.dart`:

```dart
import 'package:equatable/equatable.dart';

class {FeatureName} extends Equatable {
  const {FeatureName}({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
```

### 4. Create data/models/{feature_name}_model.dart

Follow the pattern from
`lib/presentation/home/data/models/product_model.dart`:

```dart
import 'dart:convert';

import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';
import 'package:skelter/utils/typedef.dart';

class {FeatureName}Model extends {FeatureName} {
  const {FeatureName}Model({
    required super.id,
    required super.name,
  });

  {FeatureName}Model copyWith({
    String? id,
    String? name,
  }) {
    return {FeatureName}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory {FeatureName}Model.fromJson(String source) =>
      {FeatureName}Model.fromMap(
        jsonDecode(source) as DataMap,
      );

  {FeatureName}Model.fromMap(DataMap map)
      : this(
          id: map['id'] as String,
          name: map['name'] as String,
        );

  DataMap toMap() => {
        'id': id,
        'name': name,
      };

  String toJson() => jsonEncode(toMap());
}
```

### 5. Create domain/repositories/{feature_name}_repository.dart

Follow the pattern from
`lib/presentation/home/domain/repositories/product_repository.dart`:

```dart
import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';
import 'package:skelter/utils/typedef.dart';

mixin {FeatureName}Repository {
  ResultFuture<List<{FeatureName}>> get{FeatureName}s();
}
```

### 6. Create data/datasources/{feature_name}_remote_data_source.dart

Follow the pattern from
`lib/presentation/home/data/datasources/product_remote_data_source.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/presentation/{feature_name}/data/models/{feature_name}_model.dart';
import 'package:skelter/utils/typedef.dart';

mixin {FeatureName}RemoteDatasource {
  Future<List<{FeatureName}Model>> get{FeatureName}s();
}

const kGet{FeatureName}sEndpoint = '/{feature_name}s';

class {FeatureName}RemoteDataSrcImpl
    implements {FeatureName}RemoteDatasource {
  {FeatureName}RemoteDataSrcImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<{FeatureName}Model>> get{FeatureName}s() async {
    try {
      final response = await _dio.get(
        kGet{FeatureName}sEndpoint,
      );

      if (response.statusCode != 200) {
        throw APIException(
          message: response.data,
          statusCode: response.statusCode ?? 500,
        );
      }

      return List<DataMap>.from(response.data as List)
          .map(
            (item) => {FeatureName}Model.fromMap(item),
          )
          .toList();
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }
}
```

### 7. Create data/repositories/{feature_name}_repository_impl.dart

Follow the pattern from
`lib/presentation/home/data/repositories/product_repository_impl.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/{feature_name}/data/datasources/{feature_name}_remote_data_source.dart';
import 'package:skelter/presentation/{feature_name}/data/models/{feature_name}_model.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';
import 'package:skelter/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart';
import 'package:skelter/utils/typedef.dart';

class {FeatureName}RepositoryImpl
    with {FeatureName}Repository {
  const {FeatureName}RepositoryImpl(
    this._remoteDatasource,
  );

  final {FeatureName}RemoteDatasource _remoteDatasource;

  @override
  ResultFuture<List<{FeatureName}>> get{FeatureName}s() async {
    try {
      final List<{FeatureName}Model> result =
          await _remoteDatasource.get{FeatureName}s();
      return Right(result);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }
}
```

### 8. Create domain/usecases/get_{feature_name}s.dart

Follow the pattern from
`lib/presentation/home/domain/usecases/get_products.dart`:

```dart
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';
import 'package:skelter/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart';
import 'package:skelter/utils/typedef.dart';

class Get{FeatureName}s
    with UseCaseWithoutParams<List<{FeatureName}>> {
  const Get{FeatureName}s(this._repository);

  final {FeatureName}Repository _repository;

  @override
  ResultFuture<List<{FeatureName}>> call() async =>
      _repository.get{FeatureName}s();
}
```

### 9. Create bloc/{feature_name}_state.dart

Follow the pattern from
`lib/presentation/product_detail/bloc/product_detail_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';

class {FeatureName}State with EquatableMixin {
  final List<{FeatureName}> items;
  final String? errorMessage;

  const {FeatureName}State({
    required this.items,
    this.errorMessage,
  });

  const {FeatureName}State.initial()
      : items = const [],
        errorMessage = null;

  {FeatureName}State.copy({FeatureName}State state)
      : items = state.items,
        errorMessage = state.errorMessage;

  {FeatureName}State copyWith({
    List<{FeatureName}>? items,
    String? errorMessage,
  }) {
    return {FeatureName}State(
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @visibleForTesting
  const {FeatureName}State.test({
    this.items = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [items, errorMessage];
}

class {FeatureName}LoadingState extends {FeatureName}State {
  {FeatureName}LoadingState({FeatureName}State state)
      : super.copy(state.copyWith());
}

class {FeatureName}LoadedState extends {FeatureName}State {
  {FeatureName}LoadedState(
    {FeatureName}State state, {
    required List<{FeatureName}> items,
  }) : super.copy(state.copyWith(items: items));
}

class {FeatureName}ErrorState extends {FeatureName}State {
  {FeatureName}ErrorState(
    {FeatureName}State state, {
    required String errorMessage,
  }) : super.copy(
          state.copyWith(errorMessage: errorMessage),
        );
}
```

### 10. Create bloc/{feature_name}_event.dart

Follow the pattern from
`lib/presentation/product_detail/bloc/product_detail_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class {FeatureName}Event with EquatableMixin {
  const {FeatureName}Event();
}

class Get{FeatureName}DataEvent extends {FeatureName}Event {
  const Get{FeatureName}DataEvent();

  @override
  List<Object?> get props => [];
}
```

### 11. Create bloc/{feature_name}_bloc.dart

Follow the pattern from
`lib/presentation/product_detail/bloc/product_detail_bloc.dart`:

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/domain/usecases/get_{feature_name}s.dart';

class {FeatureName}Bloc
    extends Bloc<{FeatureName}Event, {FeatureName}State> {
  {FeatureName}Bloc({
    required Get{FeatureName}s get{FeatureName}s,
  })  : _get{FeatureName}s = get{FeatureName}s,
        super(const {FeatureName}State.initial()) {
    _setupEventListeners();
  }

  final Get{FeatureName}s _get{FeatureName}s;

  void _setupEventListeners() {
    on<Get{FeatureName}DataEvent>(
      _onGet{FeatureName}DataEvent,
      transformer: droppable(),
    );
  }

  void _onGet{FeatureName}DataEvent(
    Get{FeatureName}DataEvent event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit({FeatureName}LoadingState(state));

    final result = await _get{FeatureName}s();

    result.fold(
      (failure) => emit(
        {FeatureName}ErrorState(
          state,
          errorMessage: failure.errorMessage,
        ),
      ),
      (items) => emit(
        {FeatureName}LoadedState(state, items: items),
      ),
    );
  }
}
```

### 12. Create screens/{feature_name}_screen.dart

Follow the pattern from
`lib/presentation/product_detail/product_detail_screen.dart`:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_event.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/widgets/{feature_name}_body.dart';
import 'package:skelter/utils/extensions/build_context_ext.dart';

@RoutePage()
class {FeatureName}Screen extends StatelessWidget {
  const {FeatureName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<{FeatureName}Bloc>(
      create: (_) =>
          {FeatureName}Bloc(get{FeatureName}s: sl())
            ..add(const Get{FeatureName}DataEvent()),
      child: BlocListener<
          {FeatureName}Bloc,
          {FeatureName}State>(
        listenWhen: (previous, current) =>
            current is {FeatureName}ErrorState,
        listener: _listenStateChanged,
        child: const {FeatureName}Body(),
      ),
    );
  }

  void _listenStateChanged(
    BuildContext context,
    {FeatureName}State state,
  ) {
    if (state is {FeatureName}ErrorState) {
      context.showSnackBar(
        state.errorMessage ??
            context.localization
                .opps_something_went_wrong,
      );
    }
  }
}
```

**Key patterns:**
- `BlocProvider(create: ...)` for BLoC lifecycle management
- `listenWhen` filters listener to only error states (avoids
  unnecessary listener calls)
- Use cases injected via `sl()` from GetIt

### 13. Create widgets/{feature_name}_body.dart

Follow the `context.select` pattern from
`lib/presentation/product_detail/product_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_bloc.dart';
import 'package:skelter/presentation/{feature_name}/bloc/{feature_name}_state.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{feature_name}.dart';

class {FeatureName}Body extends StatelessWidget {
  const {FeatureName}Body({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<{FeatureName}Bloc, bool>(
      (bloc) => bloc.state is {FeatureName}LoadingState,
    );

    final items = context
        .select<{FeatureName}Bloc, List<{FeatureName}>>(
      (bloc) => bloc.state.items,
    );

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index].name),
            );
          },
        ),
      ),
    );
  }
}
```

**Key patterns:**
- Use `context.select<BlocType, T>()` for selective rebuilds
  (preferred over `BlocBuilder` in this codebase)
- Each `context.select` only rebuilds when that specific value
  changes
- Side effects (navigation, snackbars) go in `BlocListener`
  in the parent screen, not here

---

### Widget Pattern Reference

| Need | Widget/API | When to use |
|------|-----------|-------------|
| Read one value | `context.select<Bloc, T>()` | Loading flag, item list |
| Rebuild on full state | `BlocBuilder` + `buildWhen` | Rare; prefer `context.select` |
| Side effects | `BlocListener` + `listenWhen` | Error handling, navigation |
| Both | `BlocConsumer` | Avoid unless truly needed |

This codebase prefers `context.select` over `BlocBuilder` /
`BlocSelector` widgets

### 14. Post-creation message

After creating all files, output the list of created files and
remind the user to:

1. Run `/register-feature {FeatureName}` to wire DI and routes
2. Customize the entity fields in the entity and model files
3. Update the API endpoint in the data source file
4. Run `fvm flutter pub run build_runner build --delete-conflicting-outputs`
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
