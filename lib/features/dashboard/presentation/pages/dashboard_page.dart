import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/auth_guard_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'biometric_test_page.dart';

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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getTokenStatus(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                              tokenInfo['hasAccessToken']
                                  ? '✅ Available'
                                  : '❌ Not Available',
                              tokenInfo['hasAccessToken']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            _buildStatusRow(
                              'Refresh Token',
                              tokenInfo['hasRefreshToken']
                                  ? '✅ Available'
                                  : '❌ Not Available',
                              tokenInfo['hasRefreshToken']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            _buildStatusRow(
                              'Token Status',
                              tokenInfo['isExpired'] ? '❌ Expired' : '✅ Valid',
                              tokenInfo['isExpired']
                                  ? Colors.red
                                  : Colors.green,
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
                                tokenInfo['timeUntilExpiration']! > 300
                                    ? Colors.green
                                    : Colors.orange,
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
            // Biometric Authentication Card
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
                          Icons.fingerprint,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Biometric Authentication',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getAuthStatus(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading auth status',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        
                        final authStatus = snapshot.data;
                        if (authStatus == null) {
                          return const Text('No auth status available');
                        }
                        
                        return Column(
                          children: [
                            _buildStatusRow(
                              'Biometric Available',
                              authStatus['isBiometricEnabled'] ? '✅ Yes' : '❌ No',
                              authStatus['isBiometricEnabled'] ? Colors.green : Colors.red,
                            ),
                            if (authStatus['biometricTypes'] != null && 
                                (authStatus['biometricTypes'] as List).isNotEmpty)
                              _buildStatusRow(
                                'Available Methods',
                                (authStatus['biometricTypes'] as List).join(', '),
                                Colors.blue,
                              ),
                            _buildStatusRow(
                              'Biometric Required',
                              authStatus['needsBiometric'] ? '✅ Yes' : '❌ No',
                              authStatus['needsBiometric'] ? Colors.orange : Colors.grey,
                            ),
                            _buildStatusRow(
                              'App Access',
                              authStatus['canAccessApp'] ? '✅ Granted' : '❌ Denied',
                              authStatus['canAccessApp'] ? Colors.green : Colors.red,
                            ),
                            const SizedBox(height: 16),
                            if (authStatus['needsBiometric'] == true)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _triggerBiometricAuth(context),
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text('Authenticate with Biometrics'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
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
            // Biometric Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BiometricTestPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.science),
                label: const Text('Test Biometric Authentication'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
      final secureStorage = SecureStorageService(const FlutterSecureStorage());
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

  // Helper method to get auth status
  Future<Map<String, dynamic>> _getAuthStatus(BuildContext context) async {
    try {
      final authGuard = AuthGuardService(
        SecureStorageService(const FlutterSecureStorage()),
        BiometricAuthService(LocalAuthentication()),
      );
      return await authGuard.getAuthStatus();
    } catch (e) {
      return {
        'hasValidToken': false,
        'isBiometricEnabled': false,
        'needsBiometric': false,
        'canAccessApp': false,
        'error': e.toString(),
      };
    }
  }

  // Helper method to trigger biometric authentication
  Future<void> _triggerBiometricAuth(BuildContext context) async {
    try {
      final authGuard = AuthGuardService(
        SecureStorageService(const FlutterSecureStorage()),
        BiometricAuthService(LocalAuthentication()),
      );
      
      final result = await authGuard.authenticateIfRequired();
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Biometric authentication successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the page to update status
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Biometric authentication failed or cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
