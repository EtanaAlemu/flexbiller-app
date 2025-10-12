import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../widgets/subscription_card_widget.dart';
import '../widgets/subscriptions_search_bar.dart';
import '../widgets/subscriptions_empty_state.dart';
import '../widgets/subscriptions_loading_widget.dart';
import '../widgets/subscriptions_error_widget.dart';
import '../pages/subscription_details_page.dart';
import '../pages/create_subscription_page.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchBar = false;
  bool _isSearching = false;
  String _selectedFilter = 'all'; // all, active, cancelled, paused
  String _sortBy = 'recent'; // recent, name, amount, date

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<SubscriptionsBloc>().add(LoadRecentSubscriptions());
    } else {
      setState(() {
        _isSearching = true;
      });
      // For now, we'll use LoadRecentSubscriptions and filter client-side
      // TODO: Implement server-side search when SearchSubscriptions event is added
      context.read<SubscriptionsBloc>().add(LoadRecentSubscriptions());
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    context.read<SubscriptionsBloc>().add(LoadRecentSubscriptions());
  }

  void _onCloseSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showSearchBar = false;
    });
    context.read<SubscriptionsBloc>().add(LoadRecentSubscriptions());
  }

  Future<void> _onRefresh() async {
    context.read<SubscriptionsBloc>().add(RefreshRecentSubscriptions());
  }

  void toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (_showSearchBar) {
        _searchFocusNode.requestFocus();
      } else {
        _searchFocusNode.unfocus();
        _onCloseSearch();
      }
    });
  }

  List<Subscription> _filterSubscriptions(List<Subscription> subscriptions) {
    List<Subscription> filtered = subscriptions;

    // Apply search filter
    if (_isSearching && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((subscription) {
        return subscription.productName.toLowerCase().contains(query) ||
            subscription.planName.toLowerCase().contains(query) ||
            subscription.state.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((subscription) {
        switch (_selectedFilter) {
          case 'active':
            return subscription.state.toUpperCase() == 'ACTIVE';
          case 'cancelled':
            return subscription.state.toUpperCase() == 'CANCELLED';
          case 'paused':
            return subscription.state.toUpperCase() == 'PAUSED';
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  List<Subscription> _sortSubscriptions(List<Subscription> subscriptions) {
    List<Subscription> sorted = List.from(subscriptions);

    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'amount':
        // Sort by price if available
        sorted.sort((a, b) {
          final aPrice = a.prices.isNotEmpty ? a.prices.first.price : 0.0;
          final bPrice = b.prices.isNotEmpty ? b.prices.first.price : 0.0;
          return bPrice.compareTo(aPrice); // Descending order
        });
        break;
      case 'date':
        sorted.sort(
          (a, b) => b.startDate.compareTo(a.startDate),
        ); // Descending order
        break;
      case 'recent':
      default:
        // Keep original order (most recent first)
        break;
    }

    return sorted;
  }

  void _navigateToDetails(Subscription subscription) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailsPage(
          subscriptionId: subscription.subscriptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          if (_showSearchBar)
            SubscriptionsSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onClear: _onClearSearch,
              onClose: _onCloseSearch,
            ),

          // Main Content
          Expanded(
            child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
              builder: (context, state) {
                if (state is SubscriptionsLoading) {
                  return const SubscriptionsLoadingWidget();
                } else if (state is RecentSubscriptionsLoaded) {
                  // Apply client-side filtering and sorting
                  List<Subscription> filteredSubscriptions =
                      _filterSubscriptions(state.subscriptions);
                  filteredSubscriptions = _sortSubscriptions(
                    filteredSubscriptions,
                  );

                  if (filteredSubscriptions.isEmpty) {
                    return SubscriptionsEmptyState(
                      isSearching: _isSearching,
                      onRefresh: _onRefresh,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredSubscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription = filteredSubscriptions[index];
                        return SubscriptionCardWidget(
                          subscription: subscription,
                          onTap: () => _navigateToDetails(subscription),
                        );
                      },
                    ),
                  );
                } else if (state is SubscriptionsError) {
                  return SubscriptionsErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<SubscriptionsBloc>().add(
                        LoadRecentSubscriptions(),
                      );
                    },
                  );
                }

                return const SubscriptionsEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSubscription,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Subscription'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  void _createNewSubscription() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSubscriptionPage()),
    );
  }
}
