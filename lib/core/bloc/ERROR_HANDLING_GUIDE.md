# BLoC Error Handling Guide

## Overview

All BLoCs should use the `BlocErrorHandlerMixin` for consistent error handling across the application.

## Usage

### 1. Add the Mixin to Your BLoC

```dart
import '../../../../core/bloc/bloc_error_handler_mixin.dart';

@injectable
class MyFeatureBloc extends Bloc<MyFeatureEvent, MyFeatureState>
    with BlocErrorHandlerMixin {
  // Your BLoC code
}
```

### 2. Handling Either<Failure, T> Results

When your use case returns `Either<Failure, T>`, use the mixin's helper methods:

```dart
Future<void> _onLoadData(
  LoadData event,
  Emitter<MyFeatureState> emit,
) async {
  emit(MyFeatureLoading());
  
  final result = await _getDataUseCase();
  
  final data = handleEitherResult(
    result,
    context: 'load_data',
    onError: (message) {
      emit(MyFeatureError(message: message));
    },
  );
  
  if (data != null) {
    emit(MyFeatureLoaded(data: data));
  }
}
```

### 3. Handling Exceptions

For try-catch blocks, use `handleException()`:

```dart
Future<void> _onCreateItem(
  CreateItem event,
  Emitter<MyFeatureState> emit,
) async {
  try {
    emit(MyFeatureLoading());
    final item = await _createItemUseCase(event.item);
    emit(MyFeatureItemCreated(item: item));
  } catch (e) {
    final message = handleException(
      e,
      context: 'create_item',
      metadata: {'itemId': event.item.id},
    );
    emit(MyFeatureError(message: message));
  }
}
```

### 4. Using executeWithErrorHandling

For simpler error handling:

```dart
Future<void> _onLoadData(
  LoadData event,
  Emitter<MyFeatureState> emit,
) async {
  emit(MyFeatureLoading());
  
  final data = await executeWithErrorHandling(
    () => _getDataUseCase(),
    context: 'load_data',
    onError: (message) {
      emit(MyFeatureError(message: message));
    },
  );
  
  if (data != null) {
    emit(MyFeatureLoaded(data: data));
  }
}
```

### 5. Using executeEitherWithErrorHandling

For use cases that return Either:

```dart
Future<void> _onDeleteItem(
  DeleteItem event,
  Emitter<MyFeatureState> emit,
) async {
  emit(MyFeatureLoading());
  
  final success = await executeEitherWithErrorHandling(
    () => _deleteItemUseCase(event.itemId),
    context: 'delete_item',
    onError: (message) {
      emit(MyFeatureError(message: message));
    },
  );
  
  if (success != null) {
    emit(MyFeatureItemDeleted(itemId: event.itemId));
  }
}
```

## Error Contexts

Always provide meaningful context for better error messages:

- `'products'` - For product-related operations
- `'payments'` - For payment-related operations
- `'accounts'` - For account-related operations
- `'invoices'` - For invoice-related operations
- `'subscriptions'` - For subscription-related operations
- `'auth'` or `'login'` - For authentication
- `'create'` or `'save'` - For creation/saving
- `'update'` - For updates
- `'delete'` - For deletions

## Benefits

1. **Consistent Error Messages**: All errors are converted to user-friendly messages
2. **Automatic Logging**: Errors are automatically logged with context
3. **Centralized Handling**: All error handling logic is in one place
4. **Easy Maintenance**: Update error messages in one place affects all features
5. **Better Debugging**: Consistent error logging makes debugging easier

## Migration Guide

### Before (Inconsistent)

```dart
try {
  final result = await _useCase();
  result.fold(
    (failure) {
      emit(ErrorState(failure.message));
    },
    (data) {
      emit(SuccessState(data));
    },
  );
} catch (e) {
  emit(ErrorState(e.toString()));
}
```

### After (Standardized)

```dart
final result = await _useCase();
final data = handleEitherResult(
  result,
  context: 'my_feature',
  onError: (message) {
    emit(ErrorState(message: message));
  },
);

if (data != null) {
  emit(SuccessState(data: data));
}
```

