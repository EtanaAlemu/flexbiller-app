# CustomSnackBar Component

A modern, reusable SnackBar component for the FlexBiller app that provides consistent styling and behavior across the entire application.

## Features

- 🎨 **Modern Design**: Floating SnackBars with rounded corners and proper spacing
- 🌙 **Theme Aware**: Automatically adapts to light/dark themes
- 🎯 **Predefined Types**: Success, Error, Warning, Info, Coming Soon, Loading
- ⚙️ **Customizable**: Full control over colors, icons, actions, and timing
- 📱 **Responsive**: Works perfectly on all screen sizes
- ♿ **Accessible**: Proper contrast ratios and touch targets

## Quick Start

```dart
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';

// Basic usage
CustomSnackBar.show(
  context,
  message: 'Hello World!',
  icon: Icons.info_outline_rounded,
);

// Success message
CustomSnackBar.showSuccess(
  context,
  message: 'Operation completed successfully!',
  actionLabel: 'View',
  onActionPressed: () => Navigator.pop(context),
);

// Error message
CustomSnackBar.showError(
  context,
  message: 'Something went wrong!',
  actionLabel: 'Retry',
  onActionPressed: () => _retryOperation(),
);
```

## Available Methods

### 1. Generic Show Method

```dart
CustomSnackBar.show(
  context,
  message: 'Custom message',
  icon: Icons.star_outline_rounded,
  backgroundColor: Colors.purple,
  actionLabel: 'Action',
  onActionPressed: () => print('Action pressed'),
  duration: Duration(seconds: 4),
);
```

### 2. Success Messages

```dart
CustomSnackBar.showSuccess(
  context,
  message: 'Data saved successfully!',
  actionLabel: 'View',
  onActionPressed: () => _navigateToDetails(),
);
```

### 3. Error Messages

```dart
CustomSnackBar.showError(
  context,
  message: 'Failed to save data',
  actionLabel: 'Retry',
  onActionPressed: () => _retrySave(),
);
```

### 4. Warning Messages

```dart
CustomSnackBar.showWarning(
  context,
  message: 'Please check your input',
);
```

### 5. Info Messages

```dart
CustomSnackBar.showInfo(
  context,
  message: 'New feature available!',
  actionLabel: 'Learn More',
  onActionPressed: () => _showFeatureInfo(),
);
```

### 6. Coming Soon Messages

```dart
CustomSnackBar.showComingSoon(
  context,
  feature: 'Advanced Analytics',
);
```

### 7. Loading Messages

```dart
CustomSnackBar.showLoading(
  context,
  message: 'Processing your request...',
);
```

### 8. Primary Theme Messages

```dart
CustomSnackBar.showPrimary(
  context,
  message: 'Welcome to FlexBiller!',
  icon: Icons.star_outline_rounded,
  actionLabel: 'Get Started',
  onActionPressed: () => _startOnboarding(),
);
```

## Parameters

| Parameter         | Type               | Default                  | Description                      |
| ----------------- | ------------------ | ------------------------ | -------------------------------- |
| `context`         | `BuildContext`     | Required                 | The build context                |
| `message`         | `String`           | Required                 | The message to display           |
| `actionLabel`     | `String?`          | `null`                   | Label for the action button      |
| `onActionPressed` | `VoidCallback?`    | `null`                   | Callback when action is pressed  |
| `icon`            | `IconData?`        | `null`                   | Icon to display (varies by type) |
| `backgroundColor` | `Color?`           | Theme-based              | Background color                 |
| `duration`        | `Duration`         | `3 seconds`              | How long to show the SnackBar    |
| `behavior`        | `SnackBarBehavior` | `floating`               | SnackBar behavior                |
| `margin`          | `EdgeInsets`       | `16px all`               | Margin around the SnackBar       |
| `shape`           | `ShapeBorder?`     | `RoundedRectangleBorder` | Custom shape                     |

## Color Scheme

The component uses a consistent color scheme:

- **Success**: `#10B981` (Green-500)
- **Error**: `#EF4444` (Red-500)
- **Warning**: `#F59E0B` (Amber-500)
- **Info**: `#3B82F6` (Blue-500)
- **Primary**: Theme-based blue (`#1E3A8A` dark, `#3B82F6` light)
- **Loading**: `#6B7280` (Gray-500)

## Examples in the App

### Tag Management

```dart
// Tag created successfully
CustomSnackBar.showSuccess(
  context,
  message: 'Tag "Marketing" created successfully!',
);

// Export completed
CustomSnackBar.showSuccess(
  context,
  message: 'Successfully exported 25 tags to tags.xlsx',
  actionLabel: 'Open',
  onActionPressed: () => _openFile(),
);
```

### Authentication

```dart
// Login failed
CustomSnackBar.showError(
  context,
  message: 'Invalid credentials. Please try again.',
  actionLabel: 'Retry',
  onActionPressed: () => _retryLogin(),
);
```

### Feature Announcements

```dart
// Coming soon feature
CustomSnackBar.showComingSoon(
  context,
  feature: 'Bulk Import',
);
```

## Migration from Standard SnackBar

Replace existing SnackBar implementations:

**Before:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 3),
  ),
);
```

**After:**

```dart
CustomSnackBar.showSuccess(
  context,
  message: 'Success!',
);
```

## Best Practices

1. **Use appropriate types**: Choose the right method for your message type
2. **Keep messages concise**: Aim for clear, brief messages
3. **Provide actions when helpful**: Use action buttons for retry, view, or dismiss
4. **Consider duration**: Longer messages need more time to read
5. **Test on different themes**: Ensure readability in both light and dark modes

## Accessibility

- High contrast ratios for text readability
- Proper touch targets for action buttons
- Screen reader friendly with semantic labels
- Consistent spacing and sizing

## Performance

- Lightweight implementation
- No unnecessary rebuilds
- Efficient memory usage
- Smooth animations
