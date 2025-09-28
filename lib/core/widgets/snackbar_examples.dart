import 'package:flutter/material.dart';
import 'custom_snackbar.dart';

/// Example usage of CustomSnackBar throughout the app
class SnackBarExamples {
  /// Example: Success message after creating a tag
  static void showTagCreatedSuccess(BuildContext context, String tagName) {
    CustomSnackBar.showSuccess(
      context,
      message: 'Tag "$tagName" created successfully!',
      actionLabel: 'View',
      onActionPressed: () {
        // Navigate to tags page or specific tag
        Navigator.pop(context);
      },
    );
  }

  /// Example: Error message when tag creation fails
  static void showTagCreationError(BuildContext context, String error) {
    CustomSnackBar.showError(
      context,
      message: 'Failed to create tag: $error',
      actionLabel: 'Retry',
      onActionPressed: () {
        // Retry tag creation
        Navigator.pop(context);
      },
    );
  }

  /// Example: Coming soon message for features
  static void showComingSoon(BuildContext context, String feature) {
    CustomSnackBar.showComingSoon(context, feature: feature);
  }

  /// Example: Export success message
  static void showExportSuccess(
    BuildContext context,
    int count,
    String fileName,
  ) {
    CustomSnackBar.showSuccess(
      context,
      message: 'Successfully exported $count items to $fileName',
      actionLabel: 'Open',
      onActionPressed: () {
        // Open the exported file
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );
  }

  /// Example: Delete confirmation
  static void showDeleteSuccess(BuildContext context, int count) {
    CustomSnackBar.showSuccess(
      context,
      message: 'Successfully deleted $count items',
    );
  }

  /// Example: Network error
  static void showNetworkError(BuildContext context) {
    CustomSnackBar.showError(
      context,
      message:
          'Network connection failed. Please check your internet connection.',
      actionLabel: 'Retry',
      onActionPressed: () {
        // Retry the operation
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );
  }

  /// Example: Authentication error
  static void showAuthError(BuildContext context) {
    CustomSnackBar.showError(
      context,
      message: 'Authentication failed. Please log in again.',
      actionLabel: 'Login',
      onActionPressed: () {
        // Navigate to login page
        Navigator.pushNamed(context, '/login');
      },
    );
  }

  /// Example: Validation error
  static void showValidationError(BuildContext context, String field) {
    CustomSnackBar.showWarning(context, message: 'Please enter a valid $field');
  }

  /// Example: Loading message
  static void showLoading(BuildContext context, String operation) {
    CustomSnackBar.showLoading(context, message: '$operation in progress...');
  }

  /// Example: Custom info message
  static void showInfo(BuildContext context, String message) {
    CustomSnackBar.showInfo(context, message: message, actionLabel: 'Got it');
  }

  /// Example: Custom primary message
  static void showPrimary(BuildContext context, String message) {
    CustomSnackBar.showPrimary(
      context,
      message: message,
      icon: Icons.star_outline_rounded,
      actionLabel: 'Learn More',
      onActionPressed: () {
        // Show more information
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );
  }
}
