import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../accounts/presentation/bloc/events/accounts_event.dart';
import '../../../accounts/presentation/bloc/states/accounts_state.dart';
import '../../../accounts/presentation/widgets/accounts_filter_widget.dart';
import '../../../accounts/presentation/widgets/account_sort_selector_widget.dart';
import '../../../accounts/presentation/widgets/export_accounts_dialog.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/domain/entities/accounts_query_params.dart';

class AccountsActionMenu extends StatelessWidget {
  final GlobalKey? accountsViewKey;

  const AccountsActionMenu({Key? key, this.accountsViewKey}) : super(key: key);

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
              const Text('Search Accounts'),
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
              const Text('Filter Accounts'),
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
              const Text('Export Accounts'),
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
              const Text('Refresh'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'get_all',
          child: Row(
            children: [
              Icon(
                Icons.list_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Get All Accounts'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'multi_select',
          child: Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Multi-Select Mode'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    // Get the AccountsBloc from the current context
    final accountsBloc = context.read<AccountsBloc>();

    switch (action) {
      case 'search':
        _toggleSearchBar();
        break;
      case 'filter':
        _showFilterDialog(context);
        break;
      case 'sort':
        _showSortDialog(context);
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'refresh':
        accountsBloc.add(const RefreshAccounts());
        break;
      case 'get_all':
        accountsBloc.add(const GetAllAccounts());
        break;
      case 'multi_select':
        accountsBloc.add(const EnableMultiSelectMode());
        break;
    }
  }

  void _toggleSearchBar() {
    if (accountsViewKey?.currentState != null) {
      (accountsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _showFilterDialog(BuildContext context) {
    final accountsBloc = context.read<AccountsBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: const AccountsFilterWidget(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final accountsBloc = context.read<AccountsBloc>();
    showDialog(
      context: context,
      builder: (context) =>
          BlocProvider.value(value: accountsBloc, child: _SortDialog()),
    );
  }

  void _showExportDialog(BuildContext context) {
    // Get current accounts from the BLoC state
    final currentState = context.read<AccountsBloc>().state;
    List<Account> accountsToExport = [];

    // Handle all states that contain accounts
    if (currentState is AllAccountsLoaded) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsLoaded) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsSearchResults) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsFiltered) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsRefreshing) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsLoadingMore) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AllAccountsRefreshing) {
      accountsToExport = currentState.accounts;
    } else if (currentState is MultiSelectModeEnabled) {
      accountsToExport = currentState.selectedAccounts;
    } else if (currentState is AccountSelected) {
      accountsToExport = currentState.selectedAccounts;
    } else if (currentState is AllAccountsSelected) {
      accountsToExport = currentState.selectedAccounts;
    } else if (currentState is BulkAccountsDeleting) {
      accountsToExport = currentState.accountsToDelete;
    } else if (currentState is BulkAccountsExporting) {
      accountsToExport = currentState.accountsToExport;
    } else {
      // If no accounts are loaded, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please load accounts first before exporting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ExportAccountsDialog(accounts: accountsToExport),
    ).then((result) {
      if (result != null) {
        final format = result['format'] as String;
        // Trigger export
        context.read<AccountsBloc>().add(
          ExportAccounts(accounts: accountsToExport, format: format),
        );
      }
    });
  }
}

class _SortDialog extends StatefulWidget {
  @override
  _SortDialogState createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    // Initialize with current sort parameters from the BLoC
    final currentParams = context.read<AccountsBloc>().currentQueryParams;
    _selectedSortBy = currentParams.sortBy;
    _selectedSortOrder = currentParams.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sort Accounts',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Organize your accounts by different criteria',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: AccountSortSelectorWidget(
                  currentSortBy: _selectedSortBy,
                  currentSortOrder: _selectedSortOrder,
                  onSortChanged: (sortBy, sortOrder) {
                    setState(() {
                      _selectedSortBy = sortBy;
                      _selectedSortOrder = sortOrder;
                    });
                  },
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Cancel - just close the dialog without applying changes
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Apply the selected sort options
                      final params = AccountsQueryParams(
                        sortBy: _selectedSortBy,
                        sortOrder: _selectedSortOrder,
                      );
                      context.read<AccountsBloc>().add(
                        RefreshAccounts(params: params),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Apply Sort',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
