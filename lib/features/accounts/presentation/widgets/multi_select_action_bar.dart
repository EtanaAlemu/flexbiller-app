import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/events/accounts_event.dart';
import '../bloc/states/accounts_state.dart';

class MultiSelectActionBar extends StatelessWidget {
  final List<Account> selectedAccounts;
  final bool isAllSelected;
  final List<Account> allAccounts;

  const MultiSelectActionBar({
    Key? key,
    required this.selectedAccounts,
    required this.isAllSelected,
    required this.allAccounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (state is BulkAccountsExportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully exported ${state.exportedCount} accounts to ${state.fileName}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is BulkAccountsExportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Close button
            IconButton(
              onPressed: () => _disableMultiSelectMode(context),
              icon: const Icon(Icons.close),
              color: Colors.white,
              tooltip: 'Exit selection mode',
            ),
            const SizedBox(width: 8),
            // Selection count
            Flexible(
              child: Text(
                '${selectedAccounts.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            // Select all / Deselect all button
            Flexible(
              child: TextButton.icon(
                onPressed: () => _toggleSelectAll(context),
                icon: Icon(
                  isAllSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isAllSelected ? 'Deselect All' : 'Select All',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Export button
            IconButton(
              onPressed: selectedAccounts.isNotEmpty
                  ? () => _showExportOptions(context)
                  : null,
              icon: const Icon(Icons.file_download),
              color: Colors.white,
              tooltip: 'Export selected',
            ),
            // Delete button
            IconButton(
              onPressed: selectedAccounts.isNotEmpty
                  ? () => _showDeleteConfirmation(context)
                  : null,
              icon: const Icon(Icons.delete),
              color: Colors.white,
              tooltip: 'Delete selected',
            ),
          ],
        ),
      ),
    );
  }

  void _disableMultiSelectMode(BuildContext context) {
    context.read<AccountsBloc>().add(const DisableMultiSelectMode());
  }

  void _toggleSelectAll(BuildContext context) {
    final bloc = context.read<AccountsBloc>();
    if (isAllSelected) {
      bloc.add(const DeselectAllAccounts());
    } else {
      bloc.add(SelectAllAccounts(accounts: allAccounts));
    }
  }

  void _showExportOptions(BuildContext context) {
    final accountsBloc = context.read<AccountsBloc>();
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export ${selectedAccounts.length} accounts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export as CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAccounts(accountsBloc, 'csv');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_view),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAccounts(accountsBloc, 'excel');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportAccounts(AccountsBloc accountsBloc, String format) {
    accountsBloc.add(
      BulkExportAccounts(accounts: selectedAccounts, format: format),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final accountsBloc = context.read<AccountsBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: AlertDialog(
          title: const Text('Delete Selected Accounts'),
          content: Text(
            'Are you sure you want to delete ${selectedAccounts.length} accounts? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccounts(accountsBloc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccounts(AccountsBloc accountsBloc) {
    accountsBloc.add(BulkDeleteAccounts(accounts: selectedAccounts));
  }
}
