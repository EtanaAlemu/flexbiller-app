import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/accounts_list_widget.dart';
import '../widgets/accounts_search_widget.dart';
import '../widgets/accounts_filter_widget.dart';
import '../widgets/create_account_form.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/accounts_query_params.dart';

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
          }
        },
        child: const AccountsView(),
      ),
    );
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateAccountForm(
                onAccountCreated: () {
                  // Refresh the accounts list after creation
                  context.read<AccountsBloc>().add(const RefreshAccounts());
                },
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
}
