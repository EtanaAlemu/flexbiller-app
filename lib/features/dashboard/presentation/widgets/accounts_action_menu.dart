import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../accounts/presentation/bloc/accounts_event.dart';
import '../../../accounts/presentation/bloc/accounts_state.dart';
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
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          String currentSortBy = 'name';
          String currentSortOrder = 'ASC';

          return AlertDialog(
            title: const Text('Sort Accounts'),
            content: AccountSortSelectorWidget(
              currentSortBy: currentSortBy,
              currentSortOrder: currentSortOrder,
              onSortChanged: (sortBy, sortOrder) {
                final params = AccountsQueryParams(
                  sortBy: sortBy,
                  sortOrder: sortOrder,
                );
                context.read<AccountsBloc>().add(
                  RefreshAccounts(params: params),
                );
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
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
