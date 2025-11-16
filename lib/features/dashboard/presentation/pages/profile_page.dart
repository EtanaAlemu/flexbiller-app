import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/user_persistence_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final UserPersistenceService _userPersistenceService =
      getIt<UserPersistenceService>();

  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // First check if user is authenticated
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (!isAuthenticated) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated. Please log in again.';
            _isLoading = false;
          });
        }
        return;
      }

      // Try to get user from local database first (local-first approach)
      User? user;
      try {
        final userId = await _secureStorage.getUserId();
        if (userId != null) {
          user = await _userPersistenceService.getUserById(userId);
        }
      } catch (dbError) {
        // Continue with auth repository fallback
      }

      // If not in local database, try auth repository (which will also update the database)
      if (user == null) {
        user = await _authRepository.getCurrentUser().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(
              'User data loading timed out',
              const Duration(seconds: 10),
            );
          },
        );
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        // If no user data, try to get basic info from secure storage
        if (user == null) {
          _trySecureStorageFallback();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _logout() async {
    await _secureStorage.clearAuthTokens();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_currentUser != null) {
      final result = await showDialog(
        context: context,
        builder: (context) => EditProfileDialog(user: _currentUser!),
      );
      if (result == true) {
        // Profile was updated successfully, reload the data
        _loadUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Loading profile...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No user data available',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please log in again to view your profile',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UpdateUserSuccess) {
          // Update the local user data
          setState(() {
            _currentUser = state.user;
          });
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Profile Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative background pattern
                    Positioned(
                      top: -15,
                      right: -15,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Profile Avatar with modern design
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // User Name
                          Text(
                            _currentUser!.displayName.isNotEmpty
                                ? _currentUser!.displayName
                                : _currentUser!.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          // User Email
                          Text(
                            _currentUser!.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Role Badge with modern design
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _currentUser!.role
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons positioned at top-right
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderActionButton(
                            icon: Icons.edit_rounded,
                            onPressed: _showEditProfileDialog,
                            tooltip: 'Edit Profile',
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderActionButton(
                            icon: Icons.refresh_rounded,
                            onPressed: _loadUserData,
                            tooltip: 'Refresh Data',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('User ID', _currentUser!.id),
                      _buildInfoRow(
                        'Account Status',
                        _currentUser!.emailVerified == true
                            ? 'Verified'
                            : 'Pending Verification',
                      ),
                      _buildInfoRow(
                        'Role',
                        _currentUser!.role.replaceAll('_', ' ').toUpperCase(),
                      ),
                      if (_currentUser!.company?.isNotEmpty == true)
                        _buildInfoRow('Company', _currentUser!.company!),
                      if (_currentUser!.department?.isNotEmpty == true)
                        _buildInfoRow('Department', _currentUser!.department!),
                      if (_currentUser!.position?.isNotEmpty == true)
                        _buildInfoRow('Position', _currentUser!.position!),
                      if (_currentUser!.location?.isNotEmpty == true)
                        _buildInfoRow('Location', _currentUser!.location!),
                      if (_currentUser!.phone?.isNotEmpty == true)
                        _buildInfoRow('Phone', _currentUser!.phone!),
                      _buildInfoRow(
                        'Member Since',
                        _formatDate(_currentUser!.createdAt),
                      ),
                      _buildInfoRow(
                        'Last Updated',
                        _formatDate(_currentUser!.updatedAt),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _trySecureStorageFallback() async {
    try {
      final userId = await _secureStorage.getUserId();
      final userEmail = await _secureStorage.getUserEmail();

      if (userId != null && userEmail != null) {
        // Create a minimal user object with available data
        final fallbackUser = User(
          id: userId,
          email: userEmail,
          name: userEmail.split('@').first, // Use email prefix as name
          role: 'USER', // Default role
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (mounted) {
          setState(() {
            _currentUser = fallbackUser;
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
