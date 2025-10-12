import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bundle.dart';
import '../bloc/bundle_multiselect_bloc.dart';
import '../bloc/events/bundle_multiselect_events.dart';
import '../pages/bundle_details_page.dart';

class BundleCardWidget extends StatelessWidget {
  final Bundle bundle;
  final VoidCallback? onTap;
  final bool isMultiSelectMode;
  final bool isSelected;

  const BundleCardWidget({
    super.key,
    required this.bundle,
    this.onTap,
    this.isMultiSelectMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveSubscription = bundle.subscriptions.any(
      (sub) => sub.state == 'ACTIVE',
    );
    final hasBlockedSubscription = bundle.subscriptions.any(
      (sub) => sub.state == 'BLOCKED',
    );
    final stateColor = _getStateColor(
      hasActiveSubscription,
      hasBlockedSubscription,
      theme,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (isMultiSelectMode) {
            _toggleSelection(context);
          } else {
            _navigateToDetails(context);
          }
        },
        onLongPress: () {
          if (!isMultiSelectMode) {
            _enableMultiSelectModeAndSelect(context);
          }
          // Provide haptic feedback
          HapticFeedback.mediumImpact();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bundle Icon with optional checkbox overlay
              Stack(
                children: [
                  // Always show bundle icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),

                  // Show checkbox overlay when in multi-select mode and selected
                  if (isMultiSelectMode && isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Bundle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle ${bundle.bundleId.substring(0, 8)}...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${bundle.subscriptions.length} subscription${bundle.subscriptions.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(hasActiveSubscription, hasBlockedSubscription),
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BundleDetailsPage(bundleId: bundle.bundleId),
      ),
    );
  }

  Color _getStateColor(bool hasActive, bool hasBlocked, ThemeData theme) {
    if (hasBlocked) {
      return Colors.red;
    } else if (hasActive) {
      return Colors.green;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(bool hasActive, bool hasBlocked) {
    if (hasBlocked) {
      return 'BLOCKED';
    } else if (hasActive) {
      return 'ACTIVE';
    } else {
      return 'INACTIVE';
    }
  }

  void _toggleSelection(BuildContext context) {
    final multiSelectBloc = context.read<BundleMultiSelectBloc>();
    if (isSelected) {
      multiSelectBloc.add(DeselectBundle(bundle));
    } else {
      multiSelectBloc.add(SelectBundle(bundle));
    }
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    final multiSelectBloc = context.read<BundleMultiSelectBloc>();
    multiSelectBloc.add(EnableMultiSelectModeAndSelect(bundle));
  }
}
