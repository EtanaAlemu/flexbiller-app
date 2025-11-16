import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_kpi.dart';

class DashboardKPICards extends StatelessWidget {
  final DashboardKPI kpis;

  const DashboardKPICards({Key? key, required this.kpis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          _buildKPICard(
            context,
            title: 'Active Subscriptions',
            value: kpis.activeSubscriptions.value.toString(),
            change: kpis.activeSubscriptions.change,
            changePercent: kpis.activeSubscriptions.changePercent,
            icon: Icons.people,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildKPICard(
            context,
            title: 'Pending Invoices',
            value: kpis.pendingInvoices.value.toString(),
            change: kpis.pendingInvoices.change,
            changePercent: kpis.pendingInvoices.changePercent,
            icon: Icons.description,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildKPICard(
            context,
            title: 'Failed Payments',
            value: kpis.failedPayments.value.toString(),
            change: kpis.failedPayments.change,
            changePercent: kpis.failedPayments.changePercent,
            icon: Icons.error_outline,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildKPICard(
            context,
            title: 'Monthly Revenue',
            value: kpis.monthlyRevenue.value,
            change: kpis.monthlyRevenue.change,
            changePercent: kpis.monthlyRevenue.changePercent,
            currency: kpis.monthlyRevenue.currency,
            icon: Icons.attach_money,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required String change,
    required String changePercent,
    required IconData icon,
    required Color color,
    String? currency,
  }) {
    final changePercentValue = double.tryParse(changePercent) ?? 0.0;
    final isPositive = changePercentValue >= 0;
    final arrowIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 0.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Title and Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  // Value
                  Text(
                    currency != null
                        ? (currency.toUpperCase() == 'USD'
                              ? '\$$value'
                              : '$value $currency')
                        : value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Change indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(arrowIcon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '$changePercent%',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                      Text(
                        ' from last month',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right side: Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
