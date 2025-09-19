import 'package:flutter/material.dart';
import '../../domain/entities/account_invoice.dart';

class InvoiceDetailCard extends StatefulWidget {
  final AccountInvoice invoice;
  final VoidCallback? onTap;

  const InvoiceDetailCard({Key? key, required this.invoice, this.onTap})
    : super(key: key);

  @override
  State<InvoiceDetailCard> createState() => _InvoiceDetailCardState();
}

class _InvoiceDetailCardState extends State<InvoiceDetailCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildAmountSection(context),
                const SizedBox(height: 20),
                _buildDateSection(context),
                if (_isExpanded) ...[
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildItemsSection(context),
                  const SizedBox(height: 20),
                  _buildAdjustmentsSection(context),
                  const SizedBox(height: 20),
                  _buildTrackingSection(context),
                  const SizedBox(height: 20),
                  _buildAuditLogSection(context),
                ],
                const SizedBox(height: 16),
                _buildExpandButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.invoice.invoiceNumber,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.invoice.invoiceId}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.invoice.status),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(widget.invoice.status).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.invoice.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatCurrency(
                    widget.invoice.amount,
                    widget.invoice.currency,
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          if (widget.invoice.balance > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Outstanding Balance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(
                      widget.invoice.balance,
                      widget.invoice.currency,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.invoice.creditAdj > 0 || widget.invoice.refundAdj > 0) ...[
            const SizedBox(height: 12),
            if (widget.invoice.creditAdj > 0)
              _buildAdjustmentRow(
                context,
                'Credit Adjustment',
                widget.invoice.creditAdj,
                Colors.green,
                Icons.credit_card_outlined,
              ),
            if (widget.invoice.refundAdj > 0)
              _buildAdjustmentRow(
                context,
                'Refund Adjustment',
                widget.invoice.refundAdj,
                Colors.blue,
                Icons.refresh_outlined,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            '-${_formatCurrency(amount, widget.invoice.currency)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateItem(
            context,
            'Invoice Date',
            _formatDate(widget.invoice.invoiceDate),
            Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateItem(
            context,
            'Due Date',
            _formatDate(widget.invoice.targetDate),
            Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.outline.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    if (widget.invoice.items.isEmpty) {
      return _buildSection(
        context,
        'Invoice Items',
        Icons.list_outlined,
        const Text('No items found'),
      );
    }

    return _buildSection(
      context,
      'Invoice Items (${widget.invoice.items.length})',
      Icons.list_outlined,
      Column(
        children: widget.invoice.items.take(3).map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['description']?.toString() ?? 'Unknown Item',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (item['quantity'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Qty: ${item['quantity']}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item['amount'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatCurrency(item['amount'], widget.invoice.currency),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdjustmentsSection(BuildContext context) {
    final hasAdjustments =
        widget.invoice.creditAdj > 0 || widget.invoice.refundAdj > 0;

    if (!hasAdjustments) {
      return _buildSection(
        context,
        'Adjustments',
        Icons.tune_outlined,
        const Text('No adjustments'),
      );
    }

    return _buildSection(
      context,
      'Adjustments',
      Icons.tune_outlined,
      Column(
        children: [
          if (widget.invoice.creditAdj > 0)
            _buildAdjustmentItem(
              context,
              'Credit Adjustment',
              widget.invoice.creditAdj,
              Colors.green,
              Icons.credit_card_outlined,
            ),
          if (widget.invoice.refundAdj > 0)
            _buildAdjustmentItem(
              context,
              'Refund Adjustment',
              widget.invoice.refundAdj,
              Colors.blue,
              Icons.refresh_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '-${_formatCurrency(amount, widget.invoice.currency)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(BuildContext context) {
    if (widget.invoice.trackingIds.isEmpty) {
      return _buildSection(
        context,
        'Tracking',
        Icons.track_changes_outlined,
        const Text('No tracking IDs'),
      );
    }

    return _buildSection(
      context,
      'Tracking IDs (${widget.invoice.trackingIds.length})',
      Icons.track_changes_outlined,
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.invoice.trackingIds.map((id) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  id,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuditLogSection(BuildContext context) {
    if (widget.invoice.auditLogs.isEmpty) {
      return _buildSection(
        context,
        'Activity Log',
        Icons.history_outlined,
        const Text('No activity recorded'),
      );
    }

    return _buildSection(
      context,
      'Recent Activity (${widget.invoice.auditLogs.length})',
      Icons.history_outlined,
      Column(
        children: widget.invoice.auditLogs.take(3).map((log) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.changeType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDate(log.changeDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (log.changedBy.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'By: ${log.changedBy}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (log.comments?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            log.comments!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isExpanded ? 'Show Less Details' : 'Show More Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      case 'partially_paid':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.blue;
      case 'pending':
        return Colors.amber;
      case 'overdue':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(dynamic amount, String? currency) {
    if (amount == null) return 'N/A';
    final currencySymbol = currency == 'USD' ? '\$' : currency ?? '';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        return 'Invalid date';
      }
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
