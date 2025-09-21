# Back Button Handler Service

## Overview

The `BackButtonHandlerService` provides a double-tap back button functionality to prevent accidental app exits. This is particularly useful for main menu screens and authentication flows where users might accidentally press the back button.

## Features

- **Double-tap to exit**: Users must press the back button twice within 2 seconds to exit the app
- **Visual feedback**: Shows a snackbar message when the first back press is detected
- **Configurable messages**: Custom exit messages for different contexts
- **Automatic state reset**: Resets the double-tap state after the timeout period
- **Logging**: Comprehensive logging for debugging

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import '../../core/widgets/back_button_handler_widget.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackButtonHandlerWidget(
      exitMessage: 'Press back again to exit the app',
      child: Scaffold(
        // Your page content
      ),
    );
  }
}
```

### Dashboard/Main Menu Usage

```dart
import 'package:flutter/material.dart';
import '../../core/widgets/back_button_handler_widget.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardBackButtonHandler(
      isMainMenu: true, // Shows appropriate exit message
      child: Scaffold(
        // Your dashboard content
      ),
    );
  }
}
```

### Advanced Usage

```dart
import 'package:flutter/material.dart';
import '../../core/widgets/back_button_handler_widget.dart';

class CustomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackButtonHandlerWidget(
      exitMessage: 'Press back again to go back',
      enableDoubleTapExit: true, // Enable/disable the feature
      showSnackBar: true, // Show/hide the snackbar message
      child: Scaffold(
        // Your page content
      ),
    );
  }
}
```

## Service Methods

### BackButtonHandlerService

- `handleBackButton(context, {exitMessage, showSnackBar})`: Main method to handle back button presses
- `reset()`: Reset the double-tap state
- `isWaitingForDoubleTap`: Check if currently waiting for a double-tap

## Widgets

### BackButtonHandlerWidget

A general-purpose wrapper that adds double-tap exit functionality to any widget.

**Parameters:**

- `child`: The widget to wrap
- `exitMessage`: Custom message to show in snackbar
- `enableDoubleTapExit`: Enable/disable the feature (default: true)
- `showSnackBar`: Show/hide the snackbar (default: true)

### DashboardBackButtonHandler

A specialized wrapper for dashboard and main menu screens with appropriate messaging.

**Parameters:**

- `child`: The widget to wrap
- `isMainMenu`: Whether this is a main menu screen (affects the message)

## Implementation Details

- Uses `WillPopScope` to intercept back button presses
- 2-second timeout for double-tap detection
- Automatic state cleanup after timeout
- Floating snackbar with action button for immediate exit
- Comprehensive logging for debugging

## Integration Points

The back button handler is integrated into:

1. **Authentication Flow Page**: Handles back button during login/authentication
2. **Login Page**: Prevents accidental exit during login
3. **Dashboard Page**: Main app navigation with context-aware messaging

## Customization

You can customize the behavior by:

1. **Changing the timeout**: Modify `_doubleTapDelay` in the service
2. **Custom messages**: Provide different messages for different contexts
3. **Disabling features**: Use `enableDoubleTapExit` and `showSnackBar` parameters
4. **Styling**: Customize the snackbar appearance in `_showExitMessage`

## Testing

The service includes comprehensive logging to help with testing and debugging. Check the console output for:

- First tap detection
- Double-tap detection
- State resets
- Timeout expiration

## Best Practices

1. **Use appropriate messages**: Different contexts should have different exit messages
2. **Consider user context**: Main menu vs. sub-pages should have different behaviors
3. **Test thoroughly**: Ensure the double-tap works as expected
4. **Monitor performance**: The service is lightweight but monitor for any issues
5. **Handle edge cases**: Consider what happens during navigation transitions
