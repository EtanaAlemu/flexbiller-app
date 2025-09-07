import 'package:flutter/material.dart';

class PlaceholderTabWidget extends StatelessWidget {
  final String tabName;

  const PlaceholderTabWidget({Key? key, required this.tabName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$tabName Tab',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'This tab is coming soon',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
