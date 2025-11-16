import 'package:flutter/material.dart';

/// View mode option
enum ViewMode { list, grid }

/// Shared view mode selection dialog
class ViewModeDialog extends StatelessWidget {
  final String title;
  final ViewMode? currentMode;
  final Function(ViewMode mode) onModeSelected;

  const ViewModeDialog({
    Key? key,
    this.title = 'View Mode',
    this.currentMode,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: const Text('Choose your preferred view mode:'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onModeSelected(ViewMode.list);
          },
          child: const Text('List View'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onModeSelected(ViewMode.grid);
          },
          child: const Text('Grid View'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  /// Show the view mode dialog
  static void show(
    BuildContext context, {
    String title = 'View Mode',
    ViewMode? currentMode,
    required Function(ViewMode mode) onModeSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => ViewModeDialog(
        title: title,
        currentMode: currentMode,
        onModeSelected: onModeSelected,
      ),
    );
  }
}
