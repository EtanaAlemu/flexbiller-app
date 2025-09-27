import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardOverviewCards extends StatelessWidget {
  final int totalAccounts;
  final int activeAccounts;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final double totalRevenue;
  final double monthlyRevenue;

  const DashboardOverviewCards({
    Key? key,
    required this.totalAccounts,
    required this.activeAccounts,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.totalRevenue,
    required this.monthlyRevenue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12, // Reduced spacing
      mainAxisSpacing: 12, // Reduced spacing
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3, // Adjusted ratio for better height
      padding: const EdgeInsets.all(8), // Added padding
      children: [
        _buildCard(
          context,
          title: 'Total Accounts',
          value: totalAccounts.toString(),
          subtitle: 'Active: $activeAccounts',
          icon: Icons.account_balance,
          color: AppTheme.getSuccessColor(Theme.of(context).brightness),
        ),
        _buildCard(
          context,
          title: 'Total Subscriptions',
          value: totalSubscriptions.toString(),
          subtitle: 'Active: $activeSubscriptions',
          icon: Icons.subscriptions,
          color: Colors.blue,
        ),
        _buildCard(
          context,
          title: 'Total Revenue',
          value: '\$${totalRevenue.toStringAsFixed(2)}',
          subtitle: 'All time',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildCard(
          context,
          title: 'Monthly Revenue',
          value: '\$${monthlyRevenue.toStringAsFixed(2)}',
          subtitle: 'This month',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row with icon and subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 10, // Reduced font size
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Added spacing
            // Bottom content - Fixed to prevent overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centered content
                children: [
                  // Value text with flexible sizing
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 18, // Controlled font size
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title text
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 11, // Reduced font size
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
