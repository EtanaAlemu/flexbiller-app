import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accounts_list_bloc.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import '../bloc/account_detail_bloc.dart';
import '../bloc/events/accounts_list_events.dart';
import '../bloc/states/accounts_list_states.dart' as list_states;
import '../bloc/accounts_orchestrator_bloc.dart';
import '../bloc/states/accounts_state.dart' as orchestrator_states;
import '../../../../injection_container.dart';
import '../widgets/accounts_list_widget.dart';
import '../widgets/create_account_form.dart';
import '../../domain/entities/accounts_query_params.dart';

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

    return BlocListener<AccountsListBloc, list_states.AccountsListState>(
      listener: (context, state) {
        if (state is list_states.AllAccountsLoaded) {
          CustomSnackBar.showSuccess(
            context,
            message: 'Successfully loaded ${state.totalCount} accounts',
          );
        } else if (state is list_states.AllAccountsRefreshing) {
          CustomSnackBar.showInfo(
            context,
            message: 'Refreshing all accounts...',
          );
        }
      },
      child: AccountsView(key: accountsViewKey),
    );
  }
}

class AccountsView extends StatefulWidget {
  const AccountsView({Key? key}) : super(key: key);

  @override
  State<AccountsView> createState() => AccountsViewState();
}

class AccountsViewState extends State<AccountsView>
    with TickerProviderStateMixin {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Scroll controller and FAB visibility
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  bool _isMultiSelectMode = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
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

  void _onScroll() {
    // Don't show/hide FAB during multi-select mode
    if (_isMultiSelectMode) return;

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down - hide FAB
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
        _fabAnimationController.forward();
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up - show FAB
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AccountsOrchestratorBloc>(),
      child: BlocListener<AccountsOrchestratorBloc, orchestrator_states.AccountsState>(
        listener: (context, state) {
          if (state is orchestrator_states.MultiSelectModeEnabled) {
            // Hide FAB when multi-select mode is enabled
            if (_isFabVisible) {
              setState(() {
                _isMultiSelectMode = true;
                _isFabVisible = false;
              });
              _fabAnimationController.forward();
            }
          } else if (state is orchestrator_states.MultiSelectModeDisabled) {
            // Show FAB when multi-select mode is disabled
            if (_isMultiSelectMode) {
              setState(() {
                _isMultiSelectMode = false;
                _isFabVisible = true;
              });
              _fabAnimationController.reverse();
            }
          }
        },
        child: Column(
          children: [
            // Search Bar (conditionally shown)
            if (_showSearchBar)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _clearSearch,
                            tooltip: 'Clear search',
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                  AccountsListWidget(scrollController: _scrollController),
                  // Floating Action Button with animation
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: AnimatedBuilder(
                      animation: _fabAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fabAnimation.value,
                          child: Opacity(
                            opacity: _fabAnimation.value,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                // Capture the AccountsListBloc instance before navigation
                                final accountsBloc = context
                                    .read<AccountsListBloc>();
                                final accountDetailBloc =
                                    getIt<AccountDetailBloc>();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: accountDetailBloc,
                                      child: CreateAccountForm(
                                        onAccountCreated: () {
                                          // Refresh the accounts list after creation
                                          accountsBloc.add(
                                            const RefreshAccounts(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              elevation: 4,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Account'),
                            ),
                          ),
                        );
                      },
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

  // Method to toggle search bar from outside (called by dashboard app bar)
  void toggleSearchBar() {
    _toggleSearchBar();
  }
}
