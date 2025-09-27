# Crash Analytics Implementation

This document describes the crash analytics implementation for the FlexBiller app using Firebase Crashlytics.

## Overview

The crash analytics system provides comprehensive error tracking and reporting capabilities following Clean Architecture principles. It automatically captures crashes, non-fatal errors, and custom events to help improve app stability and user experience.

## Architecture

### Core Components

1. **CrashAnalyticsService** (`lib/core/services/crash_analytics_service.dart`)

   - Abstract interface for crash analytics operations
   - Firebase Crashlytics implementation
   - Handles error recording, user identification, and custom logging

2. **CrashAnalyticsInitializer** (`lib/core/services/crash_analytics_initializer.dart`)

   - Initializes Firebase and Crashlytics
   - Sets up global error handlers
   - Configures collection settings

3. **CrashAnalyticsErrorBoundary** (`lib/core/widgets/crash_analytics_error_boundary.dart`)

   - Widget-level error boundary
   - Catches and reports widget errors
   - Provides fallback UI for error states

4. **CrashAnalyticsMixin** (`lib/core/widgets/crash_analytics_error_boundary.dart`)
   - Mixin for easy error reporting in widgets
   - Provides helper methods for common error scenarios

## Features

### Automatic Error Capture

- **Flutter Framework Errors**: Automatically captured via `FlutterError.onError`
- **Platform Errors**: Captured via `PlatformDispatcher.instance.onError`
- **Widget Errors**: Caught by `CrashAnalyticsErrorBoundary`
- **Network Errors**: Integrated with existing `ErrorHandler`

### Error Categorization

Errors are automatically categorized and tagged with:

- Error type (network, server, authentication, etc.)
- Severity level (low, medium, high, critical)
- Feature context (auth, accounts, subscriptions, etc.)
- Custom metadata

### User Context

- User ID tracking for authenticated users
- Custom user properties
- Session information
- Device and platform details

### Custom Logging

- Custom event recording
- Debug message logging
- Structured error reporting
- Performance metrics

## Usage

### Basic Error Reporting

```dart
// In any widget with CrashAnalyticsMixin
class MyWidget extends StatefulWidget with CrashAnalyticsMixin {
  @override
  void initState() {
    super.initState();

    // Report custom events
    reportError(
      Exception('Something went wrong'),
      reason: 'User action failed',
      customKeys: {'action': 'button_click'},
    );

    // Log messages
    logMessage('Widget initialized successfully');
  }
}
```

### Error Boundary Usage

```dart
// Wrap any widget with error boundary
MyWidget().withCrashAnalytics(
  feature: 'accounts',
  fallback: ErrorFallbackWidget(),
)
```

### Service Integration

```dart
// Get service instance
final crashAnalytics = GetIt.instance<CrashAnalyticsService>();

// Record custom error
await crashAnalytics.recordError(
  error,
  stackTrace,
  reason: 'API call failed',
  customKeys: {'endpoint': '/api/accounts'},
  fatal: false,
);

// Set user context
await crashAnalytics.setUserId('user123');
await crashAnalytics.setUserProperty('role', 'admin');
```

## Configuration

### Firebase Setup

1. **Android Configuration**

   - Add `google-services.json` to `android/app/`
   - Update `android/build.gradle.kts` with Google Services plugin
   - Update `android/app/build.gradle.kts` with plugin

2. **iOS Configuration**
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - No additional configuration needed

### Environment Settings

The system respects build configuration:

- **Debug Mode**: Full error collection and logging
- **Release Mode**: Production-optimized collection
- **Development**: Enhanced debugging information

## Error Types Handled

### Network Errors

- Connection timeouts
- Server errors (4xx, 5xx)
- Network connectivity issues
- API response errors

### Authentication Errors

- Login failures
- Token expiration
- Permission denied
- Session timeouts

### Business Logic Errors

- Validation failures
- Data processing errors
- Business rule violations
- State management issues

### System Errors

- Memory issues
- Storage failures
- Platform-specific errors
- Third-party service failures

## Custom Keys and Metadata

### Standard Keys

- `timestamp`: Error occurrence time
- `platform`: Operating system
- `version`: App version
- `feature`: Feature context
- `error_type`: Error classification
- `error_severity`: Impact level

### Custom Keys

- `user_id`: Current user identifier
- `session_id`: Session identifier
- `action`: User action that triggered error
- `endpoint`: API endpoint (for network errors)
- `retry_count`: Number of retry attempts

## Privacy and Security

### Data Collection

- No personal data is collected
- User IDs are anonymized
- Sensitive information is filtered
- GDPR compliant

### Data Retention

- Crash data retained for 90 days
- User data deleted on account deletion
- No cross-user data correlation

## Monitoring and Alerts

### Firebase Console

- Real-time crash monitoring
- Error trends and patterns
- User impact analysis
- Custom dashboards

### Alerting

- Critical error notifications
- Error rate thresholds
- User impact alerts
- Performance degradation warnings

## Testing

### Debug Mode

```dart
// Force crash for testing
FirebaseCrashlytics.instance.crash();

// Test error reporting
await crashAnalytics.recordError(
  Exception('Test error'),
  StackTrace.current,
  reason: 'Testing crash analytics',
);
```

### Production Monitoring

- Monitor error rates in Firebase Console
- Set up alerts for critical errors
- Track error resolution progress
- Analyze user impact

## Best Practices

### Error Reporting

1. **Report Early**: Report errors as soon as they occur
2. **Provide Context**: Include relevant metadata and context
3. **Categorize Properly**: Use appropriate error categories
4. **Avoid Spam**: Don't report the same error repeatedly

### User Experience

1. **Graceful Degradation**: Provide fallback UI for errors
2. **User Communication**: Inform users about errors when appropriate
3. **Recovery Options**: Provide retry mechanisms
4. **Error Prevention**: Fix root causes, not just symptoms

### Performance

1. **Async Reporting**: Don't block UI for error reporting
2. **Batch Operations**: Group related errors when possible
3. **Rate Limiting**: Avoid overwhelming the reporting system
4. **Local Storage**: Cache errors when offline

## Troubleshooting

### Common Issues

1. **Firebase Not Initialized**

   - Check `google-services.json` and `GoogleService-Info.plist`
   - Verify Firebase project configuration
   - Ensure proper initialization order

2. **Errors Not Appearing**

   - Check internet connectivity
   - Verify Firebase project access
   - Check collection settings
   - Review error logs

3. **Performance Impact**
   - Monitor error reporting frequency
   - Optimize custom key usage
   - Review error handling logic

### Debug Information

```dart
// Check if service is initialized
final isInitialized = GetIt.instance.isRegistered<CrashAnalyticsService>();

// Check collection status
final isEnabled = crashAnalytics.isEnabled;

// View recent logs
await crashAnalytics.log('Debug: Checking service status');
```

## Future Enhancements

### Planned Features

- **Custom Dashboards**: Advanced analytics visualization
- **Error Grouping**: Intelligent error clustering
- **Performance Metrics**: App performance tracking
- **User Journey**: Error impact on user flows

### Integration Opportunities

- **Firebase Analytics**: Combined crash and analytics data
- **Remote Config**: Dynamic error handling configuration
- **A/B Testing**: Error handling strategy testing
- **Machine Learning**: Predictive error detection

## Support

For issues or questions regarding crash analytics:

1. Check Firebase Console for error details
2. Review app logs for initialization issues
3. Verify configuration files are correct
4. Test in debug mode first
5. Contact development team for assistance

## Related Documentation

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Flutter Error Handling](https://docs.flutter.dev/testing/errors)
- [Clean Architecture Guide](../README.md)
- [Error Handling Guide](../utils/error_handling_guide.md)

