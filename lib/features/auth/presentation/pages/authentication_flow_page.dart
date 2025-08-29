import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/auth_guard_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import 'login_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

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
    _authGuard = AuthGuardService(
      SecureStorageService(FlutterSecureStorage()),
      BiometricAuthService(LocalAuthentication()),
    );
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

  void _onLoginSuccess() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Login successful, checking authentication...';
    });
    
    // Add a small delay to ensure tokens are fully written to secure storage
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkAuthentication();
      }
    });
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
