import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bundles_bloc.dart';
import '../bloc/bundles_event.dart';
import '../bloc/bundles_state.dart';
import '../bloc/bundle_multiselect_bloc.dart';
import '../bloc/states/bundle_multiselect_states.dart';
import '../widgets/bundle_card_widget.dart';
import '../widgets/bundles_search_bar.dart';
import '../widgets/bundles_empty_state.dart';
import '../widgets/bundles_loading_widget.dart';
import '../widgets/bundles_error_widget.dart';
import '../widgets/bundle_multi_select_action_bar.dart';
import 'bundle_details_page.dart';
import '../../domain/entities/bundle.dart';

class BundlesPage extends StatefulWidget {
  const BundlesPage({super.key});

  @override
  State<BundlesPage> createState() => _BundlesPageState();
}

class _BundlesPageState extends State<BundlesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchBar = false;
  bool _isSearching = false;
  String _selectedFilter = 'all'; // all, active, blocked
  String _sortBy = 'recent'; // recent, name, date

  @override
  void initState() {
    super.initState();
    context.read<BundlesBloc>().add(const LoadBundles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (_showSearchBar) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        _onSearchChanged('');
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<BundlesBloc>().add(const LoadBundles());
    } else {
      setState(() {
        _isSearching = true;
      });
      // For now, we'll use LoadBundles and filter client-side
      // TODO: Implement server-side search when SearchBundles event is added
      context.read<BundlesBloc>().add(const LoadBundles());
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  List<Bundle> _filterAndSortBundles(List<Bundle> bundles) {
    List<Bundle> filteredBundles = bundles;

    // Apply filter
    if (_selectedFilter != 'all') {
      filteredBundles = bundles.where((bundle) {
        final hasActiveSubscription = bundle.subscriptions.any(
          (sub) => sub.state == 'ACTIVE',
        );
        final hasBlockedSubscription = bundle.subscriptions.any(
          (sub) => sub.state == 'BLOCKED',
        );

        switch (_selectedFilter) {
          case 'active':
            return hasActiveSubscription && !hasBlockedSubscription;
          case 'blocked':
            return hasBlockedSubscription;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (_isSearching && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredBundles = filteredBundles.where((bundle) {
        return bundle.bundleId.toLowerCase().contains(query) ||
            bundle.subscriptions.any(
              (sub) =>
                  sub.productName.toLowerCase().contains(query) ||
                  sub.planName.toLowerCase().contains(query),
            );
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'recent':
        filteredBundles.sort((a, b) {
          final aLatestEvent = a.timeline.events.isNotEmpty
              ? a.timeline.events.first.effectiveDate
              : DateTime(1970);
          final bLatestEvent = b.timeline.events.isNotEmpty
              ? b.timeline.events.first.effectiveDate
              : DateTime(1970);
          return bLatestEvent.compareTo(aLatestEvent);
        });
        break;
      case 'name':
        filteredBundles.sort((a, b) {
          final aName = a.subscriptions.isNotEmpty
              ? a.subscriptions.first.productName
              : '';
          final bName = b.subscriptions.isNotEmpty
              ? b.subscriptions.first.productName
              : '';
          return aName.compareTo(bName);
        });
        break;
      case 'date':
        filteredBundles.sort((a, b) {
          final aDate = a.subscriptions.isNotEmpty
              ? a.subscriptions.first.startDate
              : DateTime(1970);
          final bDate = b.subscriptions.isNotEmpty
              ? b.subscriptions.first.startDate
              : DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
    }

    return filteredBundles;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BundleMultiSelectBloc, BundleMultiSelectState>(
      builder: (context, multiSelectState) {
        final multiSelectBloc = context.read<BundleMultiSelectBloc>();
        final isMultiSelectMode = multiSelectBloc.isMultiSelectMode;

        return Scaffold(
          body: Column(
            children: [
              // Multi-select action bar
              if (isMultiSelectMode)
                BundleMultiSelectActionBar(bundles: _getCurrentBundles()),

              // Search bar
              if (_showSearchBar && !isMultiSelectMode)
                BundlesSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                ),

              // Main content
              Expanded(
                child: BlocBuilder<BundlesBloc, BundlesState>(
                  builder: (context, state) {
                    if (state is BundlesLoading) {
                      return const BundlesLoadingWidget();
                    } else if (state is BundlesError) {
                      return BundlesErrorWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<BundlesBloc>().add(const LoadBundles());
                        },
                      );
                    } else if (state is BundlesLoaded) {
                      final filteredBundles = _filterAndSortBundles(
                        state.bundles,
                      );

                      if (filteredBundles.isEmpty) {
                        return BundlesEmptyState(
                          isSearching: _isSearching,
                          onRefresh: () {
                            context.read<BundlesBloc>().add(
                              const RefreshBundles(),
                            );
                          },
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<BundlesBloc>().add(
                            const RefreshBundles(),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredBundles.length,
                          itemBuilder: (context, index) {
                            final bundle = filteredBundles[index];
                            final isSelected = multiSelectBloc.isBundleSelected(
                              bundle,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BundleCardWidget(
                                bundle: bundle,
                                isMultiSelectMode: isMultiSelectMode,
                                isSelected: isSelected,
                                onTap: () {
                                  if (!isMultiSelectMode) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BundleDetailsPage(
                                          bundleId: bundle.bundleId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Bundle> _getCurrentBundles() {
    final bundlesState = context.read<BundlesBloc>().state;
    if (bundlesState is BundlesLoaded) {
      return _filterAndSortBundles(bundlesState.bundles);
    }
    return [];
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Most Recent'),
              value: 'recent',
              groupValue: _sortBy,
              onChanged: (value) {
                if (value != null) {
                  _onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Product Name'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                if (value != null) {
                  _onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Start Date'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                if (value != null) {
                  _onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  _onFilterChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Active'),
              value: 'active',
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  _onFilterChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Blocked'),
              value: 'blocked',
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  _onFilterChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
