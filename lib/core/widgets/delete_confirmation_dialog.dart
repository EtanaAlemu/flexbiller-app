import 'package:flutter/material.dart';

/// Shared delete confirmation dialog widget
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String itemName; // e.g., "payments", "products", "bundles"
  final int count;
  final String? customMessage;

  const DeleteConfirmationDialog({
    Key? key,
    required this.title,
    required this.itemName,
    required this.count,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message =
        customMessage ??
        'Are you sure you want to delete $count selected $itemName? This action cannot be undone.';

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Show the dialog and return true if user confirmed, false if cancelled
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String itemName,
    required int count,
    String? customMessage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        itemName: itemName,
        count: count,
        customMessage: customMessage,
      ),
    );
    return result ?? false;
  }
}
