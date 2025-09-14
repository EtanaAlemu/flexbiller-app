import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/auth_guard_service.dart';
import '../../../../injection_container.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../pages/login_page.dart';
import '../bloc/auth_bloc.dart';

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
  bool _prePopulateEmail = false;
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
          _prePopulateEmail = authResult['prePopulateEmail'] == true;
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
    _logger.i('✅ Login successful - Navigating directly to dashboard');

    // Since login was successful, we can go directly to dashboard
    // No need to re-validate authentication as we already know it's valid
    setState(() {
      _isLoading = false;
      _shouldShowLogin = false;
      _statusMessage = 'Login successful';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          _logger.i('🔄 Logout detected - Navigating to login page');
          setState(() {
            _isLoading = false;
            _shouldShowLogin = true;
            _statusMessage = 'Logged out successfully';
          });
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
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
      return LoginPage(
        onLoginSuccess: _onLoginSuccess,
        prePopulateEmail: _prePopulateEmail,
      );
    }

    return const DashboardPage();
  }
}
