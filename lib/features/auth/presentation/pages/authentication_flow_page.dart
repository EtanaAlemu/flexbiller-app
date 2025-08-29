import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/auth_guard_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../injection_container.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../pages/login_page.dart';

class AuthenticationFlowPage extends StatefulWidget {
  const AuthenticationFlowPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationFlowPage> createState() => _AuthenticationFlowPageState();
}

class _AuthenticationFlowPageState extends State<AuthenticationFlowPage> {
  final Logger _logger = Logger();
  late final AuthGuardService _authGuard;

  bool _isLoading = true;
  bool _shouldShowLogin = false;
  String _statusMessage = 'Checking authentication...';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _authGuard = getIt<AuthGuardService>();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      _logger.i('Starting authentication check...');

      final authResult = await _authGuard.authenticateWithFallback();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShowLogin = authResult['requiresLogin'] == true;
          _statusMessage =
              authResult['message'] ?? 'Authentication check completed';
        });

        _logger.i(
          'Authentication result: ${authResult['method']} - ${authResult['message']}',
        );
      }
    } catch (e) {
      _logger.e('Error during authentication check: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShowLogin = true;
          _statusMessage = 'Authentication error: $e';
        });
      }
    }
  }

  void _onLoginSuccess() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Login successful, verifying tokens...';
    });

    try {
      // Wait for a moment to ensure secure storage operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify that tokens are actually accessible from secure storage
      final secureStorage = getIt<SecureStorageService>();

      // Force refresh to clear any potential caching issues
      await secureStorage.forceRefresh();

      // First try to refresh token validation
      final hasToken = await secureStorage.refreshTokenValidation();

      if (hasToken) {
        _logger.i(
          'Tokens verified successfully, proceeding to authentication check',
        );
        setState(() {
          _statusMessage = 'Tokens verified, checking authentication...';
        });

        // Proceed with authentication check
        await _checkAuthentication();
      } else {
        _logger.w('Tokens not accessible after login, retrying...');
        // Wait a bit more and try again with regular validation
        await Future.delayed(const Duration(milliseconds: 500));
        final retryHasToken = await secureStorage.hasValidToken();

        if (retryHasToken) {
          _logger.i(
            'Tokens accessible on retry, proceeding to authentication check',
          );
          await _checkAuthentication();
        } else {
          _logger.e('Failed to access tokens after login');
          setState(() {
            _isLoading = false;
            _shouldShowLogin = true;
            _statusMessage = 'Failed to verify login. Please try again.';
          });
        }
      }
    } catch (e) {
      _logger.e('Error during token verification: $e');
      setState(() {
        _isLoading = false;
        _shouldShowLogin = true;
        _statusMessage = 'Error verifying login: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_shouldShowLogin) {
      return LoginPage(onLoginSuccess: _onLoginSuccess);
    }

    return const DashboardPage();
  }
}
