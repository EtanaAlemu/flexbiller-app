import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/usecases/adjust_invoice_item.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  final _adjustInvoiceItem = GetIt.instance<AdjustInvoiceItem>();
  bool _isAdjusting = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: widget.invoice.currency,
    );
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${widget.invoice.invoiceNumber}'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'adjust') {
                _showAdjustInvoiceDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'adjust',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Adjust Invoice Item'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Status Card
            _buildStatusCard(context, currencyFormat),
            const SizedBox(height: 24),

            // Invoice Overview
            _buildSectionHeader(context, 'Invoice Overview'),
            const SizedBox(height: 12),
            _buildOverviewCard(context, currencyFormat, dateFormat),
            const SizedBox(height: 24),

            // Invoice Items
            if (widget.invoice.items.isNotEmpty) ...[
              _buildSectionHeader(context, 'Invoice Items'),
              const SizedBox(height: 12),
              _buildItemsList(context, currencyFormat),
              const SizedBox(height: 24),
            ],

            // Credits & Adjustments
            if (widget.invoice.credits != null &&
                widget.invoice.credits!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Credits & Adjustments'),
              const SizedBox(height: 12),
              _buildCreditsCard(context, currencyFormat),
              const SizedBox(height: 24),
            ],

            // Parent Invoice Information
            if (widget.invoice.isParentInvoice ||
                widget.invoice.parentInvoiceId != null) ...[
              _buildSectionHeader(context, 'Parent Invoice Information'),
              const SizedBox(height: 12),
              _buildParentInvoiceCard(context),
              const SizedBox(height: 24),
            ],

            // Bundle Information
            if (widget.invoice.bundleKeys != null &&
                widget.invoice.bundleKeys!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Bundle Information'),
              const SizedBox(height: 12),
              _buildBundleCard(context),
              const SizedBox(height: 24),
            ],

            // Audit Logs (if available)
            if (widget.invoice.auditLogs.isNotEmpty) ...[
              _buildSectionHeader(context, 'Audit Logs'),
              const SizedBox(height: 12),
              _buildAuditLogsCard(context, dateFormat),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, NumberFormat currencyFormat) {
    final statusColor = _getStatusColor(widget.invoice.status);
    final statusIcon = _getStatusIcon(widget.invoice.status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(statusIcon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              widget.invoice.status.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(widget.invoice.amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (widget.invoice.balance > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Balance: ${currencyFormat.format(widget.invoice.balance)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              'Invoice Number',
              widget.invoice.invoiceNumber,
              Icons.receipt_long,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Invoice ID',
              widget.invoice.invoiceId,
              Icons.fingerprint,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Account ID',
              widget.invoice.accountId,
              Icons.account_circle,
            ),
            const Divider(),
            _buildDateRow(
              context,
              'Invoice Date',
              widget.invoice.invoiceDate,
              dateFormat,
              Icons.calendar_today,
            ),
            const Divider(),
            _buildDateRow(
              context,
              'Target Date',
              widget.invoice.targetDate,
              dateFormat,
              Icons.event,
            ),
            const Divider(),
            _buildAmountRow(
              context,
              'Total Amount',
              widget.invoice.amount,
              currencyFormat,
              Icons.attach_money,
            ),
            const Divider(),
            _buildAmountRow(
              context,
              'Balance',
              widget.invoice.balance,
              currencyFormat,
              Icons.account_balance_wallet,
              isBalance: true,
            ),
            if (widget.invoice.creditAdj > 0) ...[
              const Divider(),
              _buildAmountRow(
                context,
                'Credit Adjustment',
                widget.invoice.creditAdj,
                currencyFormat,
                Icons.add_circle,
                isCredit: true,
              ),
            ],
            if (widget.invoice.refundAdj > 0) ...[
              const Divider(),
              _buildAmountRow(
                context,
                'Refund Adjustment',
                widget.invoice.refundAdj,
                currencyFormat,
                Icons.undo,
                isRefund: true,
              ),
            ],
            const Divider(),
            _buildInfoRow(
              context,
              'Currency',
              widget.invoice.currency,
              Icons.monetization_on,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Tracking IDs',
              widget.invoice.trackingIds.join(', '),
              Icons.track_changes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: widget.invoice.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == widget.invoice.items.length - 1;

            return Column(
              children: [
                _buildItemRow(context, item, currencyFormat),
                if (!isLast) const Divider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    Map<String, dynamic> item,
    NumberFormat currencyFormat,
  ) {
    return Row(
      children: [
        Icon(
          Icons.inventory_2,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['productName']?.toString() ?? 'Unknown Product',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (item['description'] != null)
                Text(
                  item['description'].toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              if (item['quantity'] != null)
                Text(
                  'Qty: ${item['quantity']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
        if (item['amount'] != null)
          Text(
            currencyFormat.format(item['amount']),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }

  Widget _buildCreditsCard(BuildContext context, NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: widget.invoice.credits!.asMap().entries.map((entry) {
            final index = entry.key;
            final credit = entry.value;
            final isLast = index == widget.invoice.credits!.length - 1;

            return Column(
              children: [
                _buildCreditRow(context, credit, currencyFormat),
                if (!isLast) const Divider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCreditRow(
    BuildContext context,
    Map<String, dynamic> credit,
    NumberFormat currencyFormat,
  ) {
    return Row(
      children: [
        Icon(Icons.credit_card, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                credit['creditName']?.toString() ?? 'Credit',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (credit['description'] != null)
                Text(
                  credit['description'].toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
        if (credit['amount'] != null)
          Text(
            currencyFormat.format(credit['amount']),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  Widget _buildParentInvoiceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              'Is Parent Invoice',
              widget.invoice.isParentInvoice ? 'Yes' : 'No',
              Icons.family_restroom,
            ),
            if (widget.invoice.parentInvoiceId != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                'Parent Invoice ID',
                widget.invoice.parentInvoiceId!,
                Icons.link,
              ),
            ],
            if (widget.invoice.parentAccountId != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                'Parent Account ID',
                widget.invoice.parentAccountId!,
                Icons.account_tree,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBundleCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: widget.invoice.bundleKeys!.asMap().entries.map((entry) {
            final index = entry.key;
            final bundleKey = entry.value;
            final isLast = index == widget.invoice.bundleKeys!.length - 1;

            return Column(
              children: [
                _buildInfoRow(
                  context,
                  'Bundle Key ${index + 1}',
                  bundleKey,
                  Icons.inventory,
                ),
                if (!isLast) const Divider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAuditLogsCard(BuildContext context, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: widget.invoice.auditLogs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == widget.invoice.auditLogs.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.changeType,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            dateFormat.format(DateTime.parse(log.changeDate)),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                          if (log.changedBy.isNotEmpty)
                            Text(
                              'Changed by: ${log.changedBy}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          if (log.comments != null && log.comments!.isNotEmpty)
                            Text(
                              log.comments!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    String dateString,
    DateFormat dateFormat,
    IconData icon,
  ) {
    DateTime? date;
    try {
      date = DateTime.parse(dateString);
    } catch (e) {
      // Handle invalid date format
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                date != null ? dateFormat.format(date) : dateString,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount,
    NumberFormat currencyFormat,
    IconData icon, {
    bool isBalance = false,
    bool isCredit = false,
    bool isRefund = false,
  }) {
    Color amountColor = Theme.of(context).colorScheme.onSurface;
    if (isBalance && amount > 0) {
      amountColor = Colors.red;
    } else if (isCredit) {
      amountColor = Colors.green;
    } else if (isRefund) {
      amountColor = Colors.red;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isRefund ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                currencyFormat.format(amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMMITTED':
        return Colors.green;
      case 'DRAFT':
        return Colors.orange;
      case 'VOID':
        return Colors.red;
      case 'PENDING':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMMITTED':
        return Icons.check_circle;
      case 'DRAFT':
        return Icons.edit;
      case 'VOID':
        return Icons.cancel;
      case 'PENDING':
        return Icons.schedule;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.receipt_long;
    }
  }

  void _showAdjustInvoiceDialog(BuildContext context) {
    final TextEditingController invoiceItemIdController =
        TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCurrency = widget.invoice.currency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Adjust Invoice Item'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: invoiceItemIdController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Item ID',
                    hintText: 'Enter invoice item ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fingerprint),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter adjustment amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                  items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCurrency = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter adjustment description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isAdjusting
                  ? null
                  : () async {
                      if (invoiceItemIdController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          descriptionController.text.isEmpty) {
                        CustomSnackBar.show(
                          context,
                          message: 'Please fill in all fields',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                        return;
                      }

                      final amount = double.tryParse(amountController.text);
                      if (amount == null) {
                        CustomSnackBar.show(
                          context,
                          message: 'Please enter a valid amount',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                        return;
                      }

                      setDialogState(() {
                        _isAdjusting = true;
                      });

                      try {
                        final result = await _adjustInvoiceItem.call(
                          invoiceId: widget.invoice.invoiceId,
                          invoiceItemId: invoiceItemIdController.text,
                          accountId: widget.invoice.accountId,
                          amount: amount,
                          currency: selectedCurrency,
                          description: descriptionController.text,
                        );

                        result.fold(
                          (failure) {
                            CustomSnackBar.show(
                              context,
                              message:
                                  'Failed to adjust invoice: ${failure.message}',
                              backgroundColor: Colors.red,
                              icon: Icons.error,
                            );
                          },
                          (_) {
                            CustomSnackBar.show(
                              context,
                              message: 'Invoice item adjusted successfully',
                              backgroundColor: Colors.green,
                              icon: Icons.check_circle,
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      } catch (e) {
                        CustomSnackBar.show(
                          context,
                          message: 'An error occurred: $e',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                      } finally {
                        setDialogState(() {
                          _isAdjusting = false;
                        });
                      }
                    },
              child: _isAdjusting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Adjust'),
            ),
          ],
        ),
      ),
    );
  }
}
