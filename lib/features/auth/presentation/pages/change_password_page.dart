import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/localization/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../../../../injection_container.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.i('🔐 ChangePasswordPage initialized');
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _logger.i('🔐 ChangePasswordPage disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              _logger.i(
                '🎉 Change Password Success State Received: ${state.message}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _logger.i('🔙 Navigating back to previous page');
              Navigator.of(context).pop();
            } else if (state is ChangePasswordFailure) {
              _logger.e(
                '❌ Change Password Failure State Received: ${state.message}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ChangePasswordLoading) {
              _logger.i('⏳ Change Password Loading State Received');
            }
          },
          builder: (context, state) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmallScreen = screenHeight < 700;

            void submitForm() {
              _logger.i('📝 Change Password Form Submitted');
              _logger.d(
                '📝 Form Validation: ${_formKey.currentState?.validate()}',
              );

              if (_formKey.currentState!.validate()) {
                _logger.i(
                  '✅ Form validation passed, dispatching ChangePasswordRequested event',
                );
                _logger.d(
                  '📝 Password Details: Old password length: ${_oldPasswordController.text.length}, New password length: ${_newPasswordController.text.length}',
                );

                context.read<AuthBloc>().add(
                  ChangePasswordRequested(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                  ),
                );
              } else {
                _logger.w('⚠️ Form validation failed');
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      const Text(
                        'Change Your Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      const Text(
                        'Enter your current password and choose a new one.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: _obscureOldPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOldPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureOldPassword = !_obscureOldPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      if (state is ChangePasswordLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Change Password',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      // Add flexible space at the bottom to prevent overflow
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
