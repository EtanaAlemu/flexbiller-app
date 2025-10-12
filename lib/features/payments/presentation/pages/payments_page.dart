import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/payment.dart';
import '../bloc/payments_bloc.dart';
import '../widgets/payments_list_widget.dart';
import '../widgets/payments_loading_widget.dart';
import '../widgets/payments_error_widget.dart';
import '../widgets/payments_search_bar.dart';
import '../widgets/payment_multi_select_action_bar.dart';
import '../bloc/payment_multiselect_bloc.dart';
import '../bloc/states/payment_multiselect_states.dart';
import '../bloc/events/payment_multiselect_events.dart';

class PaymentsPage extends StatefulWidget {
  final GlobalKey<PaymentsViewState>? paymentsViewKey;

  const PaymentsPage({super.key, this.paymentsViewKey});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class PaymentsView extends StatefulWidget {
  const PaymentsView({Key? key}) : super(key: key);

  @override
  State<PaymentsView> createState() => PaymentsViewState();
}

class PaymentsViewState extends State<PaymentsView> {
  final Logger _logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _showSearchBar = false;
  bool _isMultiSelectMode = false;
  List<Payment> _allPayments = [];
  List<Payment> _filteredPayments = [];
  List<Payment> _selectedPayments = [];

  @override
  void initState() {
    super.initState();
    _logger.d('PaymentsView: initState called');
    _logger.d('PaymentsView: Dispatching GetPaymentsEvent');
    context.read<PaymentsBloc>().add(const GetPaymentsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Public getter for accessing all payments from external classes
  List<Payment> get allPayments => _allPayments;

  void _onSearchChanged(String query) {
    _logger.d('PaymentsView: _onSearchChanged called with query: "$query"');
    if (query.isEmpty) {
      _logger.d('PaymentsView: Empty query, calling GetPaymentsEvent');
      setState(() {
        _isSearching = false;
        _filteredPayments = _allPayments;
      });
      // Call GetPaymentsEvent to get all payments
      context.read<PaymentsBloc>().add(const GetPaymentsEvent());
    } else {
      _logger.d('PaymentsView: Non-empty query, calling SearchPaymentsEvent');
      setState(() {
        _isSearching = true;
      });
      // Call SearchPaymentsEvent for real search
      context.read<PaymentsBloc>().add(SearchPaymentsEvent(query));
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredPayments = _allPayments;
    });
    // Call GetPaymentsEvent to get all payments
    context.read<PaymentsBloc>().add(const GetPaymentsEvent());
  }

  void _onCloseSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showSearchBar = false;
      _filteredPayments = _allPayments;
    });
    // Call GetPaymentsEvent to get all payments
    context.read<PaymentsBloc>().add(const GetPaymentsEvent());
  }

  void _onRefresh() {
    _logger.d('PaymentsView: Refresh triggered');
    context.read<PaymentsBloc>().add(const RefreshPaymentsEvent());
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
      _filteredPayments = _allPayments;
    } else {
      _filteredPayments = _allPayments.where((payment) {
        if (payment.transactions.isEmpty) return false;
        return payment.transactions.first.status.toUpperCase() == status;
      }).toList();
    }
    setState(() {});
  }

  void sortPayments(String sortType) {
    setState(() {
      switch (sortType) {
        case 'date_desc':
          _filteredPayments.sort((a, b) {
            if (a.transactions.isEmpty || b.transactions.isEmpty) return 0;
            return b.transactions.first.effectiveDate.compareTo(
              a.transactions.first.effectiveDate,
            );
          });
          break;
        case 'date_asc':
          _filteredPayments.sort((a, b) {
            if (a.transactions.isEmpty || b.transactions.isEmpty) return 0;
            return a.transactions.first.effectiveDate.compareTo(
              b.transactions.first.effectiveDate,
            );
          });
          break;
        case 'amount_desc':
          _filteredPayments.sort(
            (a, b) => b.purchasedAmount.compareTo(a.purchasedAmount),
          );
          break;
        case 'amount_asc':
          _filteredPayments.sort(
            (a, b) => a.purchasedAmount.compareTo(b.purchasedAmount),
          );
          break;
        case 'number':
          _filteredPayments.sort(
            (a, b) => a.paymentNumber.compareTo(b.paymentNumber),
          );
          break;
      }
    });
  }

  void refreshPayments() {
    _onRefresh();
  }

  void showPaymentStatistics() {
    if (_allPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payment data available')),
      );
      return;
    }

    final totalAmount = _allPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.purchasedAmount,
    );
    final successCount = _allPayments
        .where(
          (p) =>
              p.transactions.isNotEmpty &&
              p.transactions.first.status.toUpperCase() == 'SUCCESS',
        )
        .length;
    final pendingCount = _allPayments
        .where(
          (p) =>
              p.transactions.isNotEmpty &&
              p.transactions.first.status.toUpperCase() == 'PENDING',
        )
        .length;
    final failedCount = _allPayments
        .where(
          (p) =>
              p.transactions.isNotEmpty &&
              p.transactions.first.status.toUpperCase() == 'FAILED',
        )
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatCard('Total Payments', _allPayments.length.toString()),
            _buildStatCard(
              'Total Amount',
              '\$${totalAmount.toStringAsFixed(2)}',
            ),
            _buildStatCard('Successful', successCount.toString()),
            _buildStatCard('Pending', pendingCount.toString()),
            _buildStatCard('Failed', failedCount.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('PaymentsView: build method called');

    return BlocListener<PaymentMultiSelectBloc, PaymentMultiSelectState>(
      listener: (context, state) {
        if (state is MultiSelectModeEnabled) {
          setState(() {
            _isMultiSelectMode = true;
            _selectedPayments = state.selectedPayments;
          });
        } else if (state is MultiSelectModeDisabled) {
          setState(() {
            _isMultiSelectMode = false;
            _selectedPayments = [];
          });
        } else if (state is PaymentSelected) {
          setState(() {
            _selectedPayments = state.selectedPayments;
          });
        } else if (state is PaymentDeselected) {
          setState(() {
            _selectedPayments = state.selectedPayments;
          });
        } else if (state is AllPaymentsSelected) {
          setState(() {
            _selectedPayments = state.selectedPayments;
          });
        } else if (state is AllPaymentsDeselected) {
          setState(() {
            _selectedPayments = [];
          });
        } else if (state is BulkExportCompleted) {
          // Close multi-select mode after successful export
          context.read<PaymentMultiSelectBloc>().add(
            const DisableMultiSelectMode(),
          );

          // Show custom success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Successfully exported ${_selectedPayments.length} payment(s)',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is BulkExportFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Export failed: ${state.error}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Multi-select action bar (conditionally shown)
              if (_isMultiSelectMode)
                PaymentMultiSelectActionBar(payments: _filteredPayments),

              // Search bar (conditionally shown)
              if (_showSearchBar)
                PaymentsSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  onClear: _onClearSearch,
                  onClose: _onCloseSearch,
                  isSearching: _isSearching,
                ),

              // Payments list
              Expanded(
                child: BlocBuilder<PaymentsBloc, PaymentsState>(
                  builder: (context, state) {
                    _logger.d(
                      'PaymentsView: BlocBuilder called with state: ${state.runtimeType}',
                    );

                    if (state is PaymentsLoading) {
                      _logger.d(
                        'PaymentsView: Rendering PaymentsLoadingWidget',
                      );
                      return const PaymentsLoadingWidget();
                    } else if (state is PaymentsRefreshing) {
                      _logger.d(
                        'PaymentsView: Rendering PaymentsListWidget with refreshing state',
                      );
                      _allPayments = state.payments;
                      _filteredPayments = _allPayments;
                      return PaymentsListWidget(
                        payments: _filteredPayments,
                        isRefreshing: true,
                      );
                    } else if (state is PaymentsLoaded) {
                      _logger.d(
                        'PaymentsView: Rendering PaymentsListWidget with ${state.payments.length} payments',
                      );
                      _logger.d(
                        'PaymentsView: Before update - _allPayments: ${_allPayments.length}, _filteredPayments: ${_filteredPayments.length}',
                      );
                      _allPayments = state.payments;
                      _filteredPayments = _allPayments;
                      _logger.d(
                        'PaymentsView: After update - _allPayments: ${_allPayments.length}, _filteredPayments: ${_filteredPayments.length}',
                      );
                      return PaymentsListWidget(
                        payments: _filteredPayments,
                        isRefreshing: false,
                      );
                    } else if (state is PaymentsEmpty) {
                      _logger.d(
                        'PaymentsView: Rendering empty state: ${state.message}',
                      );
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (state is PaymentsError) {
                      _logger.e(
                        'PaymentsView: Rendering PaymentsErrorWidget with error: ${state.message}',
                      );
                      return PaymentsErrorWidget(
                        message: state.message,
                        onRetry: () {
                          _logger.d('PaymentsView: Retry button pressed');
                          context.read<PaymentsBloc>().add(
                            const GetPaymentsEvent(),
                          );
                        },
                      );
                    } else {
                      _logger.d(
                        'PaymentsView: Rendering default PaymentsLoadingWidget',
                      );
                      return const PaymentsLoadingWidget();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return PaymentsView(key: widget.paymentsViewKey);
  }
}
