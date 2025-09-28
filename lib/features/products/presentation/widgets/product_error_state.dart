import 'package:flutter/material.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/entities/product.dart';

class ProductErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final List<Product>? cachedProducts;
  final AppError? appError;

  const ProductErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.cachedProducts,
    this.appError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine the appropriate icon and title based on error type
    IconData errorIcon;
    String errorTitle;
    Color iconColor;

    if (appError != null) {
      // Use AppError for better categorization
      switch (appError.runtimeType) {
        case ServerError:
          errorIcon = Icons.cloud_off_outlined;
          errorTitle = 'Service Unavailable';
          iconColor = colorScheme.tertiary;
          break;
        case NetworkError:
          errorIcon = Icons.wifi_off_outlined;
          errorTitle = 'No Internet Connection';
          iconColor = colorScheme.secondary;
          break;
        case TimeoutError:
          errorIcon = Icons.timer_off_outlined;
          errorTitle = 'Request Timeout';
          iconColor = colorScheme.primary;
          break;
        case AuthenticationError:
          errorIcon = Icons.lock_outline;
          errorTitle = 'Authentication Required';
          iconColor = colorScheme.error;
          break;
        case AuthorizationError:
          errorIcon = Icons.block_outlined;
          errorTitle = 'Access Denied';
          iconColor = colorScheme.error;
          break;
        case ValidationError:
          errorIcon = Icons.warning_outlined;
          errorTitle = 'Invalid Data';
          iconColor = colorScheme.tertiary;
          break;
        case CacheError:
          errorIcon = Icons.storage_outlined;
          errorTitle = 'Storage Error';
          iconColor = colorScheme.secondary;
          break;
        default:
          errorIcon = Icons.error_outline;
          errorTitle = 'Something went wrong';
          iconColor = colorScheme.error;
      }
    } else {
      // Fallback to message-based detection
      if (message.contains('Search service') ||
          message.contains('Products service')) {
        errorIcon = Icons.cloud_off_outlined;
        errorTitle = 'Service Unavailable';
        iconColor = colorScheme.tertiary;
      } else if (message.contains('internet connection')) {
        errorIcon = Icons.wifi_off_outlined;
        errorTitle = 'No Internet Connection';
        iconColor = colorScheme.secondary;
      } else if (message.contains('taking too long')) {
        errorIcon = Icons.timer_off_outlined;
        errorTitle = 'Request Timeout';
        iconColor = colorScheme.primary;
      } else {
        errorIcon = Icons.error_outline;
        errorTitle = 'Something went wrong';
        iconColor = colorScheme.error;
      }
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon with background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(errorIcon, size: 64, color: iconColor),
              ),
              const SizedBox(height: 24),

              // Error title
              Text(
                errorTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Cached products info
              if (cachedProducts != null && cachedProducts!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_bolt_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Showing ${cachedProducts!.length} cached products',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (cachedProducts != null && cachedProducts!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () {
                        // This would show cached products
                        // For now, just retry
                        onRetry();
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Cached'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Help text
              Text(
                'If the problem persists, please check your internet connection or try again later.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
