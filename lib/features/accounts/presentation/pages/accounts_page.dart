import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accounts_list_bloc.dart';
import '../bloc/account_detail_bloc.dart';
import '../bloc/events/accounts_list_events.dart';
import '../bloc/states/accounts_list_states.dart';
import '../../../../injection_container.dart';
import '../widgets/accounts_list_widget.dart';
import '../widgets/create_account_form.dart';
import '../../domain/entities/accounts_query_params.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class AccountsPage extends StatelessWidget {
  final GlobalKey<AccountsViewState>? accountsViewKey;

  const AccountsPage({Key? key, this.accountsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load accounts when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsListBloc>().add(
        const LoadAccounts(AccountsQueryParams()),
      );
    });

    return BlocListener<AccountsListBloc, AccountsListState>(
      listener: (context, state) {
        if (state is AllAccountsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully loaded ${state.totalCount} accounts'),
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
      child: AccountsView(key: accountsViewKey),
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

class AccountsView extends StatefulWidget {
  const AccountsView({Key? key}) : super(key: key);

  @override
  State<AccountsView> createState() => AccountsViewState();
}

class AccountsViewState extends State<AccountsView> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String searchKey) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchKey.isEmpty) {
        // If search is empty, load all accounts
        context.read<AccountsListBloc>().add(
          const LoadAccounts(AccountsQueryParams()),
        );
      } else {
        // Search accounts by search key
        context.read<AccountsListBloc>().add(SearchAccounts(searchKey));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AccountsListBloc>().add(
      const LoadAccounts(AccountsQueryParams()),
    );
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar (conditionally shown)
        if (_showSearchBar)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search accounts by name, email, or company...',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _clearSearch,
                        tooltip: 'Clear search',
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _toggleSearchBar,
                        tooltip: 'Close search',
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        // Main content
        Expanded(
          child: Stack(
            children: [
              const AccountsListWidget(),
              // Floating Action Button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    // Capture the AccountsListBloc instance before navigation
                    final accountsBloc = context.read<AccountsListBloc>();
                    final accountDetailBloc = getIt<AccountDetailBloc>();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: accountDetailBloc,
                          child: CreateAccountForm(
                            onAccountCreated: () {
                              // Refresh the accounts list after creation
                              accountsBloc.add(const RefreshAccounts());
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 4,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Account'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to toggle search bar from outside (called by dashboard app bar)
  void toggleSearchBar() {
    _toggleSearchBar();
  }
}
