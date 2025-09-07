import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../../domain/entities/account.dart';
import '../widgets/accounts_list_widget.dart';
import '../widgets/accounts_search_widget.dart';
import '../widgets/accounts_filter_widget.dart';
import '../widgets/create_account_form.dart';
import '../widgets/export_accounts_dialog.dart';
import '../widgets/account_sort_selector_widget.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/accounts_query_params.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AccountsBloc>()..add(const LoadAccounts(AccountsQueryParams())),
      child: BlocListener<AccountsBloc, AccountsState>(
        listener: (context, state) {
          if (state is AllAccountsLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully loaded ${state.totalCount} accounts',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is AllAccountsRefreshing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing all accounts...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state is AccountsExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully exported ${state.exportedCount} accounts to ${state.fileName}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    _openOrShareFile(state.filePath, state.fileName, context);
                  },
                ),
              ),
            );
          } else if (state is AccountsExportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: const AccountsView(),
      ),
    );
  }

  void _openOrShareFile(
    String filePath,
    String fileName,
    BuildContext context,
  ) async {
    try {
      // Try to open the file first
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        // If opening fails, show share dialog
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Exported accounts: $fileName');
      }
    } catch (e) {
      // If both fail, show share dialog as fallback
      try {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Exported accounts: $fileName');
      } catch (shareError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open or share file: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

class AccountsView extends StatelessWidget {
  const AccountsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state is AllAccountsLoaded) {
              return Text('Accounts (${state.totalCount})');
            }
            return const Text('Accounts');
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, state) {
              if (state is AllAccountsLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Text(
                    'Viewing all accounts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
            tooltip: 'Filter Accounts',
          ),
          BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, state) {
              String currentSortBy = 'name';
              String currentSortOrder = 'ASC';

              // Get current sort parameters from state if available
              if (state is AccountsLoaded || state is AllAccountsLoaded) {
                // For now, we'll use default values since we don't store sort params in state
                // In a real implementation, you'd store these in the state
                currentSortBy = 'name';
                currentSortOrder = 'ASC';
              }

              return AccountSortSelectorWidget(
                currentSortBy: currentSortBy,
                currentSortOrder: currentSortOrder,
                onSortChanged: (sortBy, sortOrder) {
                  // Trigger a refresh with new sort parameters
                  final params = AccountsQueryParams(
                    sortBy: sortBy,
                    sortOrder: sortOrder,
                  );
                  context.read<AccountsBloc>().add(
                    RefreshAccounts(params: params),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showExportDialog(context);
            },
            tooltip: 'Export Accounts',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AccountsBloc>().add(const RefreshAccounts());
            },
            tooltip: 'Refresh Accounts',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              context.read<AccountsBloc>().add(const GetAllAccounts());
            },
            tooltip: 'Get All Accounts',
          ),
        ],
      ),
      body: Column(
        children: [
          const AccountsSearchWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: BlocBuilder<AccountsBloc, AccountsState>(
              builder: (context, state) {
                final isLoading = state is GetAllAccountsLoading;
                final isViewingAll = state is AllAccountsLoaded;
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || isViewingAll)
                            ? null
                            : () {
                                context.read<AccountsBloc>().add(
                                  const GetAllAccounts(),
                                );
                              },
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.list),
                        label: Text(
                          isLoading
                              ? 'Loading...'
                              : isViewingAll
                              ? 'Viewing All Accounts'
                              : 'Get All Accounts',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isViewingAll
                              ? Theme.of(context).colorScheme.surfaceVariant
                              : Theme.of(context).colorScheme.secondary,
                          foregroundColor: isViewingAll
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Expanded(child: AccountsListWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Capture the AccountsBloc instance before navigation
          final accountsBloc = context.read<AccountsBloc>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: accountsBloc,
                child: CreateAccountForm(
                  onAccountCreated: () {
                    // Refresh the accounts list after creation using the captured instance
                    accountsBloc.add(const RefreshAccounts());
                  },
                ),
              ),
            ),
          );
        },
        backgroundColor: AppTheme.getSuccessColor(Theme.of(context).brightness),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AccountsFilterWidget(),
    );
  }

  void _showExportDialog(BuildContext context) {
    // Get current accounts from the BLoC state
    final currentState = context.read<AccountsBloc>().state;
    List<Account> accountsToExport = [];

    if (currentState is AllAccountsLoaded) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsLoaded) {
      accountsToExport = currentState.accounts;
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
