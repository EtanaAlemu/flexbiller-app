import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../pages/create_subscription_page.dart';
import '../pages/subscription_custom_fields_demo_page.dart';
import '../pages/block_subscription_demo_page.dart';
import '../pages/create_subscription_with_addons_demo_page.dart';
import '../pages/subscription_audit_logs_demo_page.dart';
import '../pages/update_subscription_bcd_demo_page.dart';

class SubscriptionsActionMenu extends StatelessWidget {
  final GlobalKey? subscriptionsViewKey;

  const SubscriptionsActionMenu({super.key, this.subscriptionsViewKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Button
        IconButton(
          onPressed: () => _toggleSearchBar(context),
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search Subscriptions',
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
                  Text('Create Subscription'),
                ],
              ),
            ),
            const PopupMenuItem(value: 'divider1', child: Divider()),
            const PopupMenuItem(
              value: 'custom_fields',
              child: Row(
                children: [
                  Icon(Icons.settings_input_component_rounded),
                  SizedBox(width: 12),
                  Text('Custom Fields'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_rounded),
                  SizedBox(width: 12),
                  Text('Block Subscription'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'addons',
              child: Row(
                children: [
                  Icon(Icons.add_shopping_cart_rounded),
                  SizedBox(width: 12),
                  Text('Create with Add-ons'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'audit',
              child: Row(
                children: [
                  Icon(Icons.history_rounded),
                  SizedBox(width: 12),
                  Text('Audit Logs'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bcd',
              child: Row(
                children: [
                  Icon(Icons.update_rounded),
                  SizedBox(width: 12),
                  Text('Update BCD'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleSearchBar(BuildContext context) {
    if (subscriptionsViewKey?.currentState != null) {
      (subscriptionsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        context.read<SubscriptionsBloc>().add(RefreshRecentSubscriptions());
        CustomSnackBar.showInfo(context, message: 'Subscriptions refreshed');
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
        _navigateToCreateSubscription(context);
        break;
      case 'custom_fields':
        _navigateToCustomFields(context);
        break;
      case 'block':
        _navigateToBlockSubscription(context);
        break;
      case 'addons':
        _navigateToCreateWithAddons(context);
        break;
      case 'audit':
        _navigateToAuditLogs(context);
        break;
      case 'bcd':
        _navigateToUpdateBcd(context);
        break;
    }
  }

  void _navigateToCreateSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSubscriptionPage()),
    );
  }

  void _navigateToCustomFields(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<SubscriptionsBloc>(),
          child: const SubscriptionCustomFieldsDemoPage(),
        ),
      ),
    );
  }

  void _navigateToBlockSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<SubscriptionsBloc>(),
          child: const BlockSubscriptionDemoPage(),
        ),
      ),
    );
  }

  void _navigateToCreateWithAddons(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<SubscriptionsBloc>(),
          child: const CreateSubscriptionWithAddOnsDemoPage(),
        ),
      ),
    );
  }

  void _navigateToAuditLogs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<SubscriptionsBloc>(),
          child: const SubscriptionAuditLogsDemoPage(),
        ),
      ),
    );
  }

  void _navigateToUpdateBcd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<SubscriptionsBloc>(),
          child: const UpdateSubscriptionBcdDemoPage(),
        ),
      ),
    );
  }

  void _applyFilter(BuildContext context, String filter) {
    if (subscriptionsViewKey?.currentState != null) {
      (subscriptionsViewKey!.currentState as dynamic).applyFilter(filter);
    }
    CustomSnackBar.showInfo(
      context,
      message: 'Filter applied: ${_getFilterDisplayName(filter)}',
    );
  }

  void _applySort(BuildContext context, String sort) {
    if (subscriptionsViewKey?.currentState != null) {
      (subscriptionsViewKey!.currentState as dynamic).applySort(sort);
    }
    CustomSnackBar.showInfo(
      context,
      message: 'Sort applied: ${_getSortDisplayName(sort)}',
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Subscriptions';
      case 'active':
        return 'Active Only';
      case 'cancelled':
        return 'Cancelled Only';
      case 'paused':
        return 'Paused Only';
      default:
        return 'All Subscriptions';
    }
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'recent':
        return 'Most Recent';
      case 'name':
        return 'Name (A-Z)';
      case 'amount':
        return 'Amount (High to Low)';
      case 'date':
        return 'Date (Newest First)';
      default:
        return 'Most Recent';
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Subscriptions'),
        content: const Text(
          'Choose the format for exporting your subscriptions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement CSV export
            },
            child: const Text('Export CSV'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement Excel export
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
          title: const Text('Filter Subscriptions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by subscription status:'),
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
                title: const Text('Cancelled'),
                value: 'cancelled',
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Paused'),
                value: 'paused',
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
          title: const Text('Sort Subscriptions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sort subscriptions by:'),
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
                title: const Text('Amount (High to Low)'),
                subtitle: const Text('By subscription price'),
                value: 'amount',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Date (Newest First)'),
                subtitle: const Text('By start date'),
                value: 'date',
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
