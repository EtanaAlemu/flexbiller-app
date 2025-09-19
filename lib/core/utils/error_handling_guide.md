# Centralized Error Handling Guide

This guide explains how to use the centralized error handling system throughout the FlexBiller app.

## Overview

The centralized error handling system provides:

- **User-friendly error messages** instead of technical jargon
- **Consistent error display** across all features
- **Reusable error widgets** for common error states
- **Context-aware error handling** based on the feature/action

## Core Components

### 1. ErrorHandler (`lib/core/utils/error_handler.dart`)

The main utility class that converts technical errors to user-friendly messages.

```dart
import '../../core/utils/error_handler.dart';

// Convert any error to user-friendly message
String userMessage = ErrorHandler.getUserFriendlyMessage(error, context: 'subscriptions');

// Check if error is retryable
bool canRetry = ErrorHandler.isRetryable(error);

// Get retry action text
String retryText = ErrorHandler.getRetryMessage('subscriptions');
```

### 2. ErrorDisplayWidget (`lib/core/widgets/error_display_widget.dart`)

A reusable widget for displaying errors with retry functionality.

```dart
import '../../core/widgets/error_display_widget.dart';

ErrorDisplayWidget(
  error: state.error,
  context: 'subscriptions',
  onRetry: () => _retryAction(),
  title: 'Failed to load subscriptions', // Optional
  icon: Icons.error_outline, // Optional
  showRetryButton: true, // Optional
)
```

### 3. EmptyStateWidget (`lib/core/widgets/error_display_widget.dart`)

For displaying empty states with optional actions.

```dart
EmptyStateWidget(
  message: 'No subscriptions found',
  subtitle: 'This account doesn\'t have any active subscriptions.',
  icon: Icons.subscriptions_outlined,
  onAction: () => _createSubscription(),
  actionText: 'Create Subscription',
)
```

### 4. LoadingWidget (`lib/core/widgets/error_display_widget.dart`)

For consistent loading states.

```dart
LoadingWidget(
  message: 'Loading subscriptions...',
  padding: EdgeInsets.all(16.0), // Optional
)
```

## Usage Examples

### In BLoC State Handling

```dart
// In your widget's build method
if (state is MyFeatureLoading) {
  return const LoadingWidget(message: 'Loading data...');
}

if (state is MyFeatureFailure) {
  return ErrorDisplayWidget(
    error: state.error,
    context: 'my_feature',
    onRetry: () => context.read<MyFeatureBloc>().add(LoadMyFeature()),
  );
}

if (state is MyFeatureLoaded && state.data.isEmpty) {
  return EmptyStateWidget(
    message: 'No data found',
    subtitle: 'Start by creating your first item.',
    onAction: () => _createItem(),
    actionText: 'Create Item',
  );
}
```

### In BLoC Event Handling

```dart
// In your BLoC
Future<void> _onLoadData(LoadData event, Emitter<MyFeatureState> emit) async {
  try {
    emit(MyFeatureLoading());
    final data = await _repository.getData();
    emit(MyFeatureLoaded(data));
  } catch (error) {
    // The error will be automatically converted to user-friendly message
    emit(MyFeatureFailure(ErrorHandler.getUserFriendlyMessage(error, context: 'my_feature')));
  }
}
```

### Custom Error Handling

```dart
// For specific error scenarios
try {
  await _performAction();
} catch (error) {
  if (error is DioException && error.response?.statusCode == 401) {
    // Handle authentication error specifically
    _showLoginDialog();
  } else {
    // Use centralized error handling
    _showError(ErrorHandler.getUserFriendlyMessage(error, context: 'action'));
  }
}
```

## Error Contexts

The system supports various contexts for better error messages:

- `'subscriptions'` - For subscription-related errors
- `'invoices'` - For invoice-related errors
- `'payments'` - For payment-related errors
- `'accounts'` - For account-related errors
- `'auth'` or `'login'` - For authentication errors
- `'create'` or `'save'` - For creation/saving errors
- `'update'` - For update errors
- `'delete'` - For deletion errors

## Error Types Supported

The system handles various error types:

### Network Errors

- Connection timeouts
- Network unavailability
- DNS resolution failures
- Socket exceptions

### Server Errors

- HTTP status codes (400, 401, 403, 404, 500, etc.)
- Server maintenance
- Service unavailability

### Business Logic Errors

- Validation failures
- Authentication failures
- Authorization failures
- Resource not found

### Generic Errors

- Unknown exceptions
- Unexpected errors
- Fallback messages

## Best Practices

1. **Always use context**: Provide meaningful context for better error messages
2. **Handle retry logic**: Use `ErrorHandler.isRetryable()` to determine if retry should be shown
3. **Consistent UI**: Use the provided widgets for consistent error display
4. **Log technical details**: Keep technical error details in logs for debugging
5. **User-friendly titles**: Provide clear, actionable error titles

## Migration Guide

To migrate existing error handling:

1. **Replace custom error widgets** with `ErrorDisplayWidget`
2. **Replace custom error messages** with `ErrorHandler.getUserFriendlyMessage()`
3. **Replace custom loading widgets** with `LoadingWidget`
4. **Replace custom empty states** with `EmptyStateWidget`
5. **Add context parameters** to error handling calls

## Example Migration

### Before

```dart
if (state is MyFeatureFailure) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error),
        Text('Error: ${state.error}'),
        ElevatedButton(
          onPressed: () => _retry(),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

### After

```dart
if (state is MyFeatureFailure) {
  return ErrorDisplayWidget(
    error: state.error,
    context: 'my_feature',
    onRetry: () => _retry(),
  );
}
```

This centralized approach ensures consistent, user-friendly error handling across the entire application.
