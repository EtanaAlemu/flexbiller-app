import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Service to handle back button behavior with double-tap to exit functionality
class BackButtonHandlerService {
  static final BackButtonHandlerService _instance =
      BackButtonHandlerService._internal();
  factory BackButtonHandlerService() => _instance;
  BackButtonHandlerService._internal();

  final Logger _logger = Logger();
  DateTime? _lastBackPressed;
  static const Duration _doubleTapDelay = Duration(seconds: 2);

  /// Handles back button press with double-tap to exit logic
  /// Returns true if the back button should be handled (prevent default behavior)
  /// Returns false if the back button should proceed with default behavior
  Future<bool> handleBackButton(
    BuildContext context, {
    String? exitMessage,
    bool showSnackBar = true,
    bool isMainMenu = true,
  }) async {
    final now = DateTime.now();
    final isDoubleTap =
        _lastBackPressed != null &&
        now.difference(_lastBackPressed!) < _doubleTapDelay;

    if (isDoubleTap) {
      _logger.d(
        'BackButtonHandler: Double tap detected, ${isMainMenu ? "exiting app" : "going back"}',
      );
      _lastBackPressed = null;
      return false; // Allow default back behavior
    } else {
      _lastBackPressed = now;
      _logger.d('BackButtonHandler: First tap, showing message');

      if (showSnackBar) {
        _showExitMessage(context, exitMessage);
      }

      // Set up a timer to reset the state after the delay period
      Timer(_doubleTapDelay, () {
        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) >= _doubleTapDelay) {
          _lastBackPressed = null;
          _logger.d(
            'BackButtonHandler: Double tap window expired, resetting state',
          );
        }
      });

      return true; // Prevent default back behavior
    }
  }

  /// Shows a snackbar message indicating user needs to press back again to exit
  void _showExitMessage(BuildContext context, String? customMessage) {
    final message = customMessage ?? 'Press back again to exit';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Exit',
          onPressed: () {
            // Force exit the app using SystemNavigator
            _logger.d(
              'BackButtonHandler: User tapped Exit button, forcing app exit',
            );
            SystemNavigator.pop();
          },
        ),
      ),
    );
  }

  /// Resets the back button handler state
  void reset() {
    _lastBackPressed = null;
    _logger.d('BackButtonHandler: State reset');
  }

  /// Checks if we're currently in a state where double-tap is required
  bool get isWaitingForDoubleTap =>
      _lastBackPressed != null &&
      DateTime.now().difference(_lastBackPressed!) < _doubleTapDelay;
}
