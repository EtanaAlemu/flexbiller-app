import 'package:flutter/material.dart';

class CustomSnackBar {
  /// Shows a modern, floating SnackBar with customizable content
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsets margin = const EdgeInsets.all(16),
    ShapeBorder? shape,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final defaultBackgroundColor =
        backgroundColor ??
        (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF3B82F6));

    // Default shape
    final defaultShape =
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: defaultBackgroundColor,
        behavior: behavior,
        shape: defaultShape,
        margin: margin,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed:
                    onActionPressed ??
                    () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              )
            : null,
      ),
    );
  }

  /// Shows a success SnackBar with check icon
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF10B981), // Green-500
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Shows an error SnackBar with error icon
  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFEF4444), // Red-500
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Shows a warning SnackBar with warning icon
  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFF59E0B), // Amber-500
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Shows an info SnackBar with info icon
  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF3B82F6), // Blue-500
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Shows a "Coming Soon" SnackBar with info icon
  static void showComingSoon(
    BuildContext context, {
    required String feature,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: '$feature - Coming Soon!',
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF3B82F6), // Blue-500
      actionLabel: actionLabel ?? 'Dismiss',
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Shows a loading SnackBar with loading icon
  static void showLoading(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: Icons.hourglass_empty_rounded,
      backgroundColor: const Color(0xFF6B7280), // Gray-500
      duration: duration,
    );
  }

  /// Shows a custom SnackBar with primary theme color
  static void showPrimary(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    show(
      context,
      message: message,
      icon: icon,
      backgroundColor: isDark
          ? const Color(0xFF1E3A8A) // Dark blue
          : const Color(0xFF3B82F6), // Blue-500
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }
}
