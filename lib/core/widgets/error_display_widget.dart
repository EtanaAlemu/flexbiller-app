import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// A reusable widget for displaying user-friendly error messages
class ErrorDisplayWidget extends StatelessWidget {
  final dynamic error;
  final String? context;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;
  final bool showRetryButton;
  final EdgeInsets? padding;

  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.context,
    this.onRetry,
    this.icon,
    this.title,
    this.showRetryButton = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(
      error,
      context: this.context,
    );
    final canRetry = ErrorHandler.isRetryable(error);
    final retryText = ErrorHandler.getRetryMessage(this.context);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? _getDefaultTitle(this.context),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userFriendlyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && canRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText),
              ),
            ],
            if (showRetryButton && !canRetry) ...[
              const SizedBox(height: 16),
              Text(
                'Please contact support if this problem persists.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle(String? context) {
    switch (context?.toLowerCase()) {
      case 'subscriptions':
        return 'Failed to load subscriptions';
      case 'invoices':
        return 'Failed to load invoices';
      case 'payments':
        return 'Failed to load payments';
      case 'accounts':
        return 'Failed to load accounts';
      case 'auth':
      case 'login':
        return 'Authentication failed';
      case 'create':
      case 'save':
        return 'Failed to save';
      case 'update':
        return 'Failed to update';
      case 'delete':
        return 'Failed to delete';
      default:
        return 'Something went wrong';
    }
  }
}

/// A specialized error widget for empty states
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final EdgeInsets? padding;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A loading widget with optional message
class LoadingWidget extends StatelessWidget {
  final String? message;
  final EdgeInsets? padding;

  const LoadingWidget({Key? key, this.message, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
