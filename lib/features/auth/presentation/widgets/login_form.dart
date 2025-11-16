import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import '../../../../core/config/build_config.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/jwt_service.dart';
import '../bloc/auth_bloc.dart';
import '../pages/forgot_password_page.dart';
import '../../../../injection_container.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final bool prePopulateEmail;

  const LoginForm({
    Key? key,
    this.onLoginSuccess,
    this.prePopulateEmail = false,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = false; // Add Remember Me state

  @override
  void initState() {
    super.initState();
    // Pre-populate with environment-specific credentials
    if (BuildConfig.isDevelopment) {
      _emailController.text = BuildConfig.email;
      _passwordController.text = BuildConfig.password;
    } else if (widget.prePopulateEmail) {
      // Pre-populate email from stored JWT token
      _prePopulateEmailFromToken();
    }
  }

  Future<void> _prePopulateEmailFromToken() async {
    try {
      final secureStorage = getIt<SecureStorageService>();
      final jwtService = getIt<JwtService>();

      final token = await secureStorage.getAuthToken();
      if (token != null) {
        final email = jwtService.getUserEmail(token);
        if (email.isNotEmpty) {
          _emailController.text = email;
        }
      }
    } catch (e) {
      // If we can't get the email, just continue without pre-populating
      _logger.w('Error pre-populating email: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          CustomSnackBar.showSuccess(context, message: AppStrings.successLogin);
          // Call the success callback if provided, otherwise navigate
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else if (state is LoginFailure) {
          CustomSnackBar.showError(
            context,
            message: '${state.title}: ${state.message}',
            actionLabel: state.isWebOnlyUser ? 'Use Web Version' : null,
            onActionPressed: state.isWebOnlyUser
                ? () {
                    // Handle web version redirect
                  }
                : null,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading || state is LoginLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              _buildHeaderSection(theme, colorScheme),
              const SizedBox(height: 48),

              // Login Form
              _buildLoginForm(theme, colorScheme, isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.account_circle,
            size: 60,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.welcomeBack,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.signInToContinue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLoading,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _buildModernTextField(
            theme: theme,
            colorScheme: colorScheme,
            controller: _emailController,
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            onFieldSubmitted: () {
              if (!isLoading) {
                _passwordFocusNode.requestFocus();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.validationRequired;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return AppStrings.validationEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password Field
          _buildModernTextField(
            theme: theme,
            colorScheme: colorScheme,
            controller: _passwordController,
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            icon: Icons.lock_outline,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            onFieldSubmitted: () {
              if (!isLoading) {
                _submitForm(context);
              }
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.validationRequired;
              }
              if (value.length < 6) {
                return AppStrings.validationPasswordLength(6);
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Remember Me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Remember Me',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _submitForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Signing in...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      AppStrings.loginButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Forgot Password Link
          Center(
            child: TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppStrings.forgotPassword,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    VoidCallback? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted != null
              ? (_) => onFieldSubmitted()
              : null,
          validator: validator,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
