import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../bloc/invoices_bloc.dart';
import '../bloc/invoice_multiselect_bloc.dart';
import '../bloc/states/invoice_multiselect_states.dart';
import '../widgets/invoices_list_widget.dart';
import '../widgets/invoices_loading_widget.dart';
import '../widgets/invoices_error_widget.dart';
import '../widgets/invoice_multiselect_action_bar.dart';
import '../widgets/invoices_search_bar.dart';
import '../../domain/entities/invoice.dart';
import '../../../../../core/widgets/custom_snackbar.dart';

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => InvoicesViewState();
}

class InvoicesViewState extends State<InvoicesView> {
  final Logger _logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _showSearchBar = false;
  bool _isMultiSelectMode = false;
  List<Invoice> _allInvoices = [];
  List<Invoice> _filteredInvoices = [];

  @override
  void initState() {
    super.initState();
    _logger.d('InvoicesView: initState called');
    _logger.d('InvoicesView: Dispatching GetInvoicesEvent');
    context.read<InvoicesBloc>().add(const GetInvoicesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Public getter for accessing all invoices from external classes
  List<Invoice> get allInvoices => _allInvoices;

  void _onSearchChanged(String query) {
    _logger.d('InvoicesView: _onSearchChanged called with query: "$query"');
    if (query.isEmpty) {
      _logger.d('InvoicesView: Empty query, calling GetInvoicesEvent');
      setState(() {
        _isSearching = false;
        _filteredInvoices = _allInvoices;
      });
      // Call GetInvoicesEvent to get all invoices
      context.read<InvoicesBloc>().add(const GetInvoicesEvent());
    } else {
      _logger.d('InvoicesView: Non-empty query, calling SearchInvoicesEvent');
      setState(() {
        _isSearching = true;
      });
      // Call SearchInvoicesEvent for real search
      context.read<InvoicesBloc>().add(SearchInvoicesEvent(query));
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredInvoices = _allInvoices;
    });
    // Call GetInvoicesEvent to get all invoices
    context.read<InvoicesBloc>().add(const GetInvoicesEvent());
  }

  void _onCloseSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showSearchBar = false;
      _filteredInvoices = _allInvoices;
    });
    // Call GetInvoicesEvent to get all invoices
    context.read<InvoicesBloc>().add(const GetInvoicesEvent());
  }

  Future<void> _onRefresh() async {
    _logger.d('InvoicesView: Refresh triggered');
    context.read<InvoicesBloc>().add(const RefreshInvoicesEvent());
  }

  // Method to toggle search bar from outside (called by dashboard app bar)
  void toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _onClearSearch();
      }
    });

    // Auto-focus when search bar is shown
    if (_showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void applyStatusFilter(String? status) {
    if (status == null) {
      _filteredInvoices = _allInvoices;
    } else {
      _filteredInvoices = _allInvoices.where((invoice) {
        return invoice.status.toUpperCase() == status;
      }).toList();
    }
    setState(() {});
  }

  void sortInvoices(String sortType) {
    List<Invoice> sortedInvoices = List.from(_filteredInvoices);

    switch (sortType) {
      case 'date_desc':
        sortedInvoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
        break;
      case 'date_asc':
        sortedInvoices.sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));
        break;
      case 'amount_desc':
        sortedInvoices.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        sortedInvoices.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'number':
        sortedInvoices.sort((a, b) {
          // Extract numeric parts from invoice numbers for proper numeric sorting
          final aNumber = _extractNumericPart(a.invoiceNumber);
          final bNumber = _extractNumericPart(b.invoiceNumber);

          // If both have numeric parts, sort numerically
          if (aNumber != null && bNumber != null) {
            return aNumber.compareTo(bNumber);
          }

          // If only one has numeric part, prioritize it
          if (aNumber != null && bNumber == null) return -1;
          if (aNumber == null && bNumber != null) return 1;

          // If neither has numeric part, fall back to alphabetical
          return a.invoiceNumber.compareTo(b.invoiceNumber);
        });
        break;
    }

    setState(() {
      _filteredInvoices = sortedInvoices;
    });
  }

  Future<void> refreshInvoices() async {
    await _onRefresh();
  }

  /// Extracts numeric part from invoice number for proper numeric sorting
  /// Handles various formats like "INV-001", "98", "INV-100", etc.
  int? _extractNumericPart(String invoiceNumber) {
    // Try to find numeric sequences in the invoice number
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(invoiceNumber);

    if (match != null) {
      return int.tryParse(match.group(0)!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoicesBloc, InvoicesState>(
      listener: (context, state) {
        if (state is InvoicesLoaded) {
          _allInvoices = state.invoices;
          _filteredInvoices = state.invoices;
        } else if (state is InvoicesRefreshing) {
          _allInvoices = state.invoices;
          _filteredInvoices = state.invoices;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Multi-select action bar (conditionally shown)
              if (_isMultiSelectMode)
                InvoiceMultiSelectActionBar(invoices: _filteredInvoices),

              // Search bar (conditionally shown)
              if (_showSearchBar)
                InvoicesSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  onClear: _onClearSearch,
                  onClose: _onCloseSearch,
                  isSearching: _isSearching,
                ),

              // Invoices list
              Expanded(
                child: BlocListener<InvoiceMultiSelectBloc, InvoiceMultiSelectState>(
                  listener: (context, state) {
                    if (state is MultiSelectModeEnabled) {
                      setState(() {
                        _isMultiSelectMode = true;
                      });
                    } else if (state is MultiSelectModeDisabled) {
                      setState(() {
                        _isMultiSelectMode = false;
                      });
                    } else if (state is InvoiceSelected) {
                      // Selection state handled by BLoC
                    } else if (state is InvoiceDeselected) {
                      // Selection state handled by BLoC
                    } else if (state is AllInvoicesSelected) {
                      // Selection state handled by BLoC
                    } else if (state is AllInvoicesDeselected) {
                      // Selection state handled by BLoC
                    } else if (state is BulkExportCompleted) {
                      CustomSnackBar.showSuccess(
                        context,
                        message:
                            'Invoices exported successfully to ${state.filePath}',
                      );
                    } else if (state is BulkExportFailed) {
                      CustomSnackBar.showError(
                        context,
                        message: 'Export failed: ${state.error}',
                      );
                    } else if (state is BulkDeleteCompleted) {
                      CustomSnackBar.showSuccess(
                        context,
                        message:
                            'Successfully deleted ${state.deletedCount} invoice(s)',
                      );
                    } else if (state is BulkDeleteFailed) {
                      CustomSnackBar.showError(
                        context,
                        message: 'Delete failed: ${state.error}',
                      );
                    }
                  },
                  child: BlocBuilder<InvoicesBloc, InvoicesState>(
                    buildWhen: (previous, current) {
                      // Only rebuild when state type changes or data changes
                      if (previous.runtimeType != current.runtimeType) {
                        return true;
                      }
                      // Rebuild if both are loaded states but data changed
                      if (previous is InvoicesLoaded &&
                          current is InvoicesLoaded) {
                        return previous.invoices.length !=
                                current.invoices.length ||
                            previous.invoices != current.invoices;
                      }
                      // Rebuild if both are refreshing states but data changed
                      if (previous is InvoicesRefreshing &&
                          current is InvoicesRefreshing) {
                        return previous.invoices.length !=
                                current.invoices.length ||
                            previous.invoices != current.invoices;
                      }
                      return false;
                    },
                    builder: (context, state) {
                      _logger.d(
                        'InvoicesView: BlocBuilder called with state: ${state.runtimeType}',
                      );

                      if (state is InvoicesLoading) {
                        _logger.d('InvoicesView: Showing loading widget');
                        return const InvoicesLoadingWidget();
                      } else if (state is InvoicesRefreshing) {
                        _logger.d(
                          'InvoicesView: Showing refreshing widget with ${state.invoices.length} invoices',
                        );
                        return InvoicesListWidget(
                          invoices: _filteredInvoices,
                          isRefreshing: true,
                          onRefresh: _onRefresh,
                        );
                      } else if (state is InvoicesLoaded) {
                        _logger.d(
                          'InvoicesView: Showing loaded widget with ${state.invoices.length} invoices',
                        );
                        return InvoicesListWidget(
                          invoices: _filteredInvoices,
                          isRefreshing: false,
                          onRefresh: _onRefresh,
                        );
                      } else if (state is InvoicesError) {
                        _logger.d(
                          'InvoicesView: Showing error widget with message: ${state.message}',
                        );
                        return InvoicesErrorWidget(message: state.message);
                      } else if (state is InvoicesEmpty) {
                        _logger.d(
                          'InvoicesView: Showing empty widget with message: ${state.message}',
                        );
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _logger.d(
                                    'InvoicesView: Retry button pressed',
                                  );
                                  context.read<InvoicesBloc>().add(
                                    const GetInvoicesEvent(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _logger.d('InvoicesView: Showing initial state');
                        return const InvoicesLoadingWidget();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
