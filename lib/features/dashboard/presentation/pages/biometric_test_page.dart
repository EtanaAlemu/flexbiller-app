import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/auth_guard_service.dart';

class BiometricTestPage extends StatefulWidget {
  const BiometricTestPage({Key? key}) : super(key: key);

  @override
  State<BiometricTestPage> createState() => _BiometricTestPageState();
}

class _BiometricTestPageState extends State<BiometricTestPage> {
  final BiometricAuthService _biometricAuth = BiometricAuthService(
    LocalAuthentication(),
  );
  final SecureStorageService _secureStorage = SecureStorageService(
    const FlutterSecureStorage(),
  );
  final AuthGuardService _authGuard = AuthGuardService(
    SecureStorageService(const FlutterSecureStorage()),
    BiometricAuthService(LocalAuthentication()),
  );

  String _status = 'Ready';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biometric Authentication Test',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _status,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _testBiometricAvailability,
                              icon: const Icon(Icons.info),
                              label: const Text(
                                'Check Biometric Availability',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _testBiometricAuth,
                              icon: const Icon(Icons.fingerprint),
                              label: const Text(
                                'Test Biometric Authentication',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _testAuthGuard,
                              icon: const Icon(Icons.security),
                              label: const Text(
                                'Test Auth Guard',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.tertiary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onTertiary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _getDetailedStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final status = snapshot.data;
                if (status == null) return const Text('No status available');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Status',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          'Biometric Available',
                          status['isBiometricEnabled'],
                        ),
                        _buildStatusRow(
                          'Has Valid Token',
                          status['hasValidToken'],
                        ),
                        _buildStatusRow(
                          'Needs Biometric',
                          status['needsBiometric'],
                        ),
                        _buildStatusRow(
                          'Can Access App',
                          status['canAccessApp'],
                        ),
                        if (status['biometricTypes'] != null)
                          _buildStatusRow(
                            'Available Methods',
                            status['biometricTypes'].join(', '),
                          ),
                        if (status['error'] != null)
                          _buildStatusRow(
                            'Error',
                            status['error'],
                            isError: true,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: TextStyle(
              color: isError ? Theme.of(context).colorScheme.error : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getDetailedStatus() async {
    return await _authGuard.getAuthStatus();
  }

  Future<void> _testBiometricAvailability() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking biometric availability...';
    });

    try {
      final isAvailable = await _biometricAuth.isBiometricAvailable();
      final hasHardware = await _biometricAuth.hasBiometricHardware();
      final biometricNames = await _biometricAuth.getAvailableBiometricNames();

      setState(() {
        _status =
            'Biometric Available: $isAvailable, Hardware: $hasHardware, Types: ${biometricNames.join(', ')}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testBiometricAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing biometric authentication...';
    });

    try {
      final result = await _biometricAuth.authenticate(
        reason: 'Please authenticate to test biometric functionality',
      );

      setState(() {
        _status = result
            ? 'Biometric authentication successful!'
            : 'Biometric authentication failed or cancelled';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuthGuard() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing auth guard...';
    });

    try {
      final canAccess = await _authGuard.canAccessApp();

      setState(() {
        _status = canAccess
            ? 'Auth guard passed - access granted!'
            : 'Auth guard failed - access denied';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
