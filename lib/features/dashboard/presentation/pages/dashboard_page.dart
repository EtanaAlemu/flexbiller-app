import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to FlexBiller',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your billing and accounts efficiently',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            // Token Status Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Authentication Status',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getTokenStatus(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading token status',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        
                        final tokenInfo = snapshot.data;
                        if (tokenInfo == null) {
                          return const Text('No token information available');
                        }
                        
                        return Column(
                          children: [
                            _buildStatusRow(
                              'Access Token',
                              tokenInfo['hasAccessToken'] ? '✅ Available' : '❌ Not Available',
                              tokenInfo['hasAccessToken'] ? Colors.green : Colors.red,
                            ),
                            _buildStatusRow(
                              'Refresh Token',
                              tokenInfo['hasRefreshToken'] ? '✅ Available' : '❌ Not Available',
                              tokenInfo['hasRefreshToken'] ? Colors.green : Colors.red,
                            ),
                            _buildStatusRow(
                              'Token Status',
                              tokenInfo['isExpired'] ? '❌ Expired' : '✅ Valid',
                              tokenInfo['isExpired'] ? Colors.red : Colors.green,
                            ),
                            if (tokenInfo['expirationTime'] != null)
                              _buildStatusRow(
                                'Expires At',
                                _formatDateTime(tokenInfo['expirationTime']),
                                Colors.blue,
                              ),
                            if (tokenInfo['timeUntilExpiration'] != null)
                              _buildStatusRow(
                                'Time Remaining',
                                '${tokenInfo['timeUntilExpiration']} seconds',
                                tokenInfo['timeUntilExpiration']! > 300 ? Colors.green : Colors.orange,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300, // Reduced height for better fit
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12, // Reduced spacing
                mainAxisSpacing: 12, // Reduced spacing
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2, // Adjust aspect ratio for better fit
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.account_balance,
                    title: 'Accounts',
                    subtitle: 'Manage customer accounts',
                    color: AppTheme.getSuccessColor(
                      Theme.of(context).brightness,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountsPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Billing',
                    subtitle: 'Create and manage invoices',
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Billing feature - Coming Soon!'),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.payment,
                    title: 'Payments',
                    subtitle: 'Track payment transactions',
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payments feature - Coming Soon!'),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Reports',
                    subtitle: 'View business analytics',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reports feature - Coming Soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              Icon(icon, size: 32, color: color), // Reduced icon size
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  // Smaller text
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to 1 line
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // Reduced spacing
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // Smaller text
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get token status
  Future<Map<String, dynamic>> _getTokenStatus(BuildContext context) async {
    try {
      final authRepository = context.read<AuthRepository>();
      return await authRepository.getTokenStatus();
    } catch (e) {
      // Fallback to secure storage service if auth repository is not available
      final secureStorage = SecureStorageService(
        const FlutterSecureStorage(),
      );
      return await secureStorage.getTokenInfo();
    }
  }

  // Helper method to build status rows
  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format date time
  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}
