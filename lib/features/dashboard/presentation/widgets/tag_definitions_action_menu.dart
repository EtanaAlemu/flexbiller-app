import 'package:flutter/material.dart';
import '../../../tag_definitions/presentation/pages/tag_definitions_page.dart';

class TagDefinitionsActionMenu extends StatelessWidget {
  final GlobalKey<TagDefinitionsViewState>? tagDefinitionsViewKey;

  const TagDefinitionsActionMenu({Key? key, this.tagDefinitionsViewKey})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        // Filter section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'FILTER & SORT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'search',
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Search Tag Definitions'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'filter',
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Filter by Type'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Sort Options'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Actions section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'ACTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Export All'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Refresh Data'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Settings section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'SETTINGS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'view_mode',
          child: Row(
            children: [
              Icon(
                Icons.view_module_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('View Mode'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'search':
        _toggleSearchBar(context);
        break;
      case 'filter':
        _showFilterOptions(context);
        break;
      case 'sort':
        _showSortOptions(context);
        break;
      case 'export':
        _exportTagDefinitions(context);
        break;
      case 'refresh':
        _refreshTagDefinitions(context);
        break;
      case 'view_mode':
        _showViewModeOptions(context);
        break;
    }
  }

  void _toggleSearchBar(BuildContext context) {
    if (tagDefinitionsViewKey?.currentState != null) {
      (tagDefinitionsViewKey!.currentState as TagDefinitionsViewState)
          .toggleSearchBar();
    }
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tag Definitions'),
        content: const Text('Filter options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Tag Definitions'),
        content: const Text('Sort options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportTagDefinitions(BuildContext context) {
    // TODO: Implement export all functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export all functionality will be implemented here.'),
      ),
    );
  }

  void _refreshTagDefinitions(BuildContext context) {
    // TODO: Implement refresh functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing tag definitions...')),
    );
  }

  void _showViewModeOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Mode'),
        content: const Text('View mode options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
