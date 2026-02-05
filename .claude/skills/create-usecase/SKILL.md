---
name: create-usecase
description: Create a UseCase class with proper mixin
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Create UseCase

Creates a UseCase class following Skelter's mixin-based pattern.

**Usage:**
- `/create-usecase GetProductReviews` — without params
- `/create-usecase GetProductReviews --with-params` — with params

The first argument is PascalCase use case name.
Use `--with-params` flag to generate a Params class.

## Steps

### 1. Parse the arguments

Extract:
- `UseCaseName` (PascalCase, e.g., `GetProductReviews`)
- `has_params` (true if `--with-params` flag is present)
- `feature_name` (snake_case, derived from context or ask user)

### 2. Determine file location

Ask the user which feature this belongs to, or infer from the
use case name. The file goes in:
`lib/presentation/{feature_name}/domain/usecases/{use_case_name}.dart`
where `{use_case_name}` is the snake_case of `UseCaseName`
(e.g., `get_product_reviews.dart`).

### 3. Determine return type

Ask the user what type the use case returns (e.g., `List<Product>`,
`ProductDetail`, `void`). Use `ResultFuture<T>` wrapper.

### 4a. Create UseCase WITHOUT params

Follow the pattern from
`lib/presentation/home/domain/usecases/get_products.dart`:

```dart
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{entity_name}.dart';
import 'package:skelter/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart';
import 'package:skelter/utils/typedef.dart';

class {UseCaseName}
    with UseCaseWithoutParams<{ReturnType}> {
  const {UseCaseName}(this._repository);

  final {FeatureName}Repository _repository;

  @override
  ResultFuture<{ReturnType}> call() async =>
      _repository.{methodName}();
}
```

**Key patterns:**
- `with UseCaseWithoutParams<T>` mixin
- `const` constructor taking repository
- Single `call()` override
- Repository stored as private final field

### 4b. Create UseCase WITH params

Follow the pattern from
`lib/presentation/product_detail/domain/usecases/get_product_detail.dart`:

```dart
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/{feature_name}/domain/entities/{entity_name}.dart';
import 'package:skelter/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart';
import 'package:skelter/utils/typedef.dart';

class {UseCaseName}Params {
  const {UseCaseName}Params({required this.id});

  final String id;
}

class {UseCaseName}
    with UseCaseWithParams<{ReturnType}, {UseCaseName}Params> {
  const {UseCaseName}(this._repository);

  final {FeatureName}Repository _repository;

  @override
  ResultFuture<{ReturnType}> call(
    {UseCaseName}Params params,
  ) async =>
      _repository.{methodName}(id: params.id);
}
```

**Key patterns:**
- Params class defined above the use case in the same file
- `const` constructor on Params class
- `with UseCaseWithParams<T, Params>` mixin
- `call()` receives the Params object

### 5. Update the repository contract

If the repository mixin doesn't already have the method, add it
to `lib/presentation/{feature_name}/domain/repositories/{feature_name}_repository.dart`.

### 6. Update the repository implementation

Add the method implementation to
`lib/presentation/{feature_name}/data/repositories/{feature_name}_repository_impl.dart`
following the try/catch `APIException` -> `Left(APIFailure)` pattern.

### 7. Update the data source

Add the corresponding method to both the data source mixin and
implementation in
`lib/presentation/{feature_name}/data/datasources/{feature_name}_remote_data_source.dart`.

### 8. Post-creation message

Remind the user to:

1. Register the use case in
   `lib/core/services/injection_container.dart` with
   `..registerLazySingleton(() => {UseCaseName}(sl()))`
2. Inject the use case into the relevant BLoC constructor
3. Customize the Params class fields if using `--with-params`

## Linting Rules to Enforce

- Use `package:skelter/...` imports only (no relative imports)
- Single quotes for all strings
- Trailing commas on all argument lists
- `const` constructors where possible
- `final` local variables
- Lines under 80 characters
- No positional boolean parameters
- Named parameters for constructor arguments
