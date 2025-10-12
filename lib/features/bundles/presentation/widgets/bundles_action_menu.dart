import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bundles_bloc.dart';
import '../bloc/bundles_event.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class BundlesActionMenu extends StatelessWidget {
  final GlobalKey? bundlesViewKey;

  const BundlesActionMenu({super.key, this.bundlesViewKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Button
        IconButton(
          onPressed: () => _toggleSearchBar(context),
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search Bundles',
        ),
        // 3-Dot Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: 'More actions',
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 12),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'filter',
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded),
                  SizedBox(width: 12),
                  Text('Filter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  Icon(Icons.sort_rounded),
                  SizedBox(width: 12),
                  Text('Sort'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'create',
              child: Row(
                children: [
                  Icon(Icons.add_rounded),
                  SizedBox(width: 12),
                  Text('Create Bundle'),
                ],
              ),
            ),
            const PopupMenuItem(value: 'divider1', child: Divider()),
            const PopupMenuItem(
              value: 'view_details',
              child: Row(
                children: [
                  Icon(Icons.visibility_rounded),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'manage_subscriptions',
              child: Row(
                children: [
                  Icon(Icons.subscriptions_rounded),
                  SizedBox(width: 12),
                  Text('Manage Subscriptions'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bundle_timeline',
              child: Row(
                children: [
                  Icon(Icons.timeline_rounded),
                  SizedBox(width: 12),
                  Text('Bundle Timeline'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'audit_logs',
              child: Row(
                children: [
                  Icon(Icons.history_rounded),
                  SizedBox(width: 12),
                  Text('Audit Logs'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleSearchBar(BuildContext context) {
    if (bundlesViewKey?.currentState != null) {
      (bundlesViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        context.read<BundlesBloc>().add(RefreshBundles());
        CustomSnackBar.showInfo(context, message: 'Bundles refreshed');
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'filter':
        _showFilterDialog(context);
        break;
      case 'sort':
        _showSortDialog(context);
        break;
      case 'create':
        _navigateToCreateBundle(context);
        break;
      case 'view_details':
        _navigateToBundleDetails(context);
        break;
      case 'manage_subscriptions':
        _navigateToManageSubscriptions(context);
        break;
      case 'bundle_timeline':
        _navigateToBundleTimeline(context);
        break;
      case 'audit_logs':
        _navigateToAuditLogs(context);
        break;
    }
  }

  void _navigateToCreateBundle(BuildContext context) {
    // TODO: Navigate to create bundle page
    CustomSnackBar.showInfo(context, message: 'Create Bundle - Coming Soon');
  }

  void _navigateToBundleDetails(BuildContext context) {
    // TODO: Navigate to bundle details page
    CustomSnackBar.showInfo(context, message: 'Bundle Details - Coming Soon');
  }

  void _navigateToManageSubscriptions(BuildContext context) {
    // TODO: Navigate to manage subscriptions page
    CustomSnackBar.showInfo(
      context,
      message: 'Manage Subscriptions - Coming Soon',
    );
  }

  void _navigateToBundleTimeline(BuildContext context) {
    // TODO: Navigate to bundle timeline page
    CustomSnackBar.showInfo(context, message: 'Bundle Timeline - Coming Soon');
  }

  void _navigateToAuditLogs(BuildContext context) {
    // TODO: Navigate to audit logs page
    CustomSnackBar.showInfo(context, message: 'Audit Logs - Coming Soon');
  }

  void _applyFilter(BuildContext context, String filter) {
    if (bundlesViewKey?.currentState != null) {
      (bundlesViewKey!.currentState as dynamic).applyFilter(filter);
    }
    CustomSnackBar.showInfo(
      context,
      message: 'Filter applied: ${_getFilterDisplayName(filter)}',
    );
  }

  void _applySort(BuildContext context, String sort) {
    if (bundlesViewKey?.currentState != null) {
      (bundlesViewKey!.currentState as dynamic).applySort(sort);
    }
    CustomSnackBar.showInfo(
      context,
      message: 'Sort applied: ${_getSortDisplayName(sort)}',
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Bundles';
      case 'active':
        return 'Active Only';
      case 'inactive':
        return 'Inactive Only';
      case 'recent':
        return 'Recent Only';
      default:
        return 'All Bundles';
    }
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'recent':
        return 'Most Recent';
      case 'name':
        return 'Name (A-Z)';
      case 'created':
        return 'Created Date';
      case 'updated':
        return 'Last Updated';
      default:
        return 'Most Recent';
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Bundles'),
        content: const Text('Choose the format for exporting your bundles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement CSV export
              CustomSnackBar.showInfo(
                context,
                message: 'CSV Export - Coming Soon',
              );
            },
            child: const Text('Export CSV'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement Excel export
              CustomSnackBar.showInfo(
                context,
                message: 'Excel Export - Coming Soon',
              );
            },
            child: const Text('Export Excel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String selectedFilter = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Bundles'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by bundle status:'),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('All'),
                value: 'all',
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Active'),
                value: 'active',
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Inactive'),
                value: 'inactive',
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Recent'),
                value: 'recent',
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilter(context, selectedFilter);
              },
              child: const Text('Apply Filter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    String selectedSort = 'recent';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sort Bundles'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sort bundles by:'),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Most Recent'),
                subtitle: const Text('Default order'),
                value: 'recent',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Name (A-Z)'),
                subtitle: const Text('Alphabetical order'),
                value: 'name',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Created Date'),
                subtitle: const Text('By creation date'),
                value: 'created',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Last Updated'),
                subtitle: const Text('By last update'),
                value: 'updated',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _applySort(context, selectedSort);
              },
              child: const Text('Apply Sort'),
            ),
          ],
        ),
      ),
    );
  }
}
