import 'package:flutter/material.dart';

/// Sort option configuration
class SortOption {
  final String title;
  final String sortBy;
  final String sortOrder;
  final IconData icon;

  const SortOption({
    required this.title,
    required this.sortBy,
    required this.sortOrder,
    required this.icon,
  });
}

/// Shared sort options bottom sheet widget
class SortOptionsBottomSheet extends StatelessWidget {
  final String title;
  final List<SortOption> options;
  final Function(String sortBy, String sortOrder) onSortSelected;

  const SortOptionsBottomSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.onSortSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...options.map(
            (option) => _buildSortOption(context, option, () {
              Navigator.pop(context);
              onSortSelected(option.sortBy, option.sortOrder);
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    SortOption option,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(option.icon),
      title: Text(option.title),
      onTap: onTap,
    );
  }

  /// Show the sort options bottom sheet
  static void show(
    BuildContext context, {
    required String title,
    required List<SortOption> options,
    required Function(String sortBy, String sortOrder) onSortSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortOptionsBottomSheet(
        title: title,
        options: options,
        onSortSelected: onSortSelected,
      ),
    );
  }
}
