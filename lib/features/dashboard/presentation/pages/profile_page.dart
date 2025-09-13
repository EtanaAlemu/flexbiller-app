import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/user_persistence_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
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
    print('DEBUG: ProfilePage initState called');

    // Test dependency injection
    try {
      print('DEBUG: Testing dependency injection...');
      print('DEBUG: AuthRepository: ${_authRepository.runtimeType}');
      print('DEBUG: SecureStorageService: ${_secureStorage.runtimeType}');
    } catch (e) {
      print('DEBUG: Dependency injection error: $e');
    }

    // Add a small delay to ensure dependencies are properly initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('DEBUG: Starting to load user data...');

      // First check if user is authenticated
      final isAuthenticated = await _authRepository.isAuthenticated();
      print('DEBUG: Is authenticated: $isAuthenticated');

      if (!isAuthenticated) {
        print('DEBUG: User not authenticated, setting error state');
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
        print('DEBUG: Attempting to load user from local database...');
        final userId = await _secureStorage.getUserId();
        if (userId != null) {
          user = await _userPersistenceService.getUserById(userId);
          if (user != null) {
            print('DEBUG: User loaded from local database: ${user.email}');
          } else {
            print(
              'DEBUG: User not found in local database, trying auth repository...',
            );
          }
        }
      } catch (dbError) {
        print('DEBUG: Error loading from local database: $dbError');
        // Continue with auth repository fallback
      }

      // If not in local database, try auth repository (which will also update the database)
      if (user == null) {
        print('DEBUG: Loading user from auth repository...');
        user = await _authRepository.getCurrentUser().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(
              'User data loading timed out',
              const Duration(seconds: 10),
            );
          },
        );
        print(
          'DEBUG: User data loaded from auth repository: ${user?.email ?? 'null'}',
        );
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        // If no user data, try to get basic info from secure storage
        if (user == null) {
          print(
            'DEBUG: No user data returned, trying secure storage fallback...',
          );
          _trySecureStorageFallback();
        }
      }
    } catch (e) {
      print('DEBUG: Error loading user data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user data: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Alternative method to check authentication status
  Future<void> _checkAuthStatus() async {
    try {
      print('DEBUG: Checking authentication status...');

      // Check secure storage directly
      final hasToken = await _secureStorage.hasValidToken();
      print('DEBUG: Has valid token: $hasToken');

      if (hasToken) {
        final tokenInfo = await _secureStorage.getTokenInfo();
        print('DEBUG: Token info: $tokenInfo');

        // Try to load user data again
        await _loadUserData();
      } else {
        print('DEBUG: No valid token found');
        if (mounted) {
          setState(() {
            _errorMessage =
                'No valid authentication token found. Please log in again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('DEBUG: Error checking auth status: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking authentication: $e';
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

  void _navigateToChangePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
  }

  /// Refresh user data from local database
  Future<void> _refreshUserData() async {
    try {
      print('DEBUG: Refreshing user data from local database...');
      final userId = await _secureStorage.getUserId();
      if (userId != null) {
        final refreshedUser = await _userPersistenceService.getUserById(userId);
        if (refreshedUser != null && mounted) {
          setState(() {
            _currentUser = refreshedUser;
          });
          print(
            'DEBUG: User data refreshed successfully: ${refreshedUser.email}',
          );
        } else {
          print(
            'DEBUG: No user found in database, reloading from auth repository...',
          );
          await _loadUserData();
        }
      } else {
        print('DEBUG: No user ID found, reloading from auth repository...');
        await _loadUserData();
      }
    } catch (e) {
      print('DEBUG: Error refreshing user data: $e');
      // Fallback to full reload
      await _loadUserData();
    }
  }

  /// Show database statistics dialog
  Future<void> _showDatabaseStats() async {
    try {
      final userCount = await _userPersistenceService.getUserCount();
      final isDatabaseEmpty = await _userPersistenceService.getAllUsers().then(
        (users) => users.isEmpty,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('Database Statistics'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogInfoRow('Total Users', '$userCount'),
                  _buildDialogInfoRow(
                    'Database Status',
                    isDatabaseEmpty ? 'Empty' : 'Populated',
                  ),
                  _buildDialogInfoRow(
                    'Current User',
                    _currentUser?.email ?? 'Unknown',
                  ),
                  _buildDialogInfoRow(
                    'Last Updated',
                    _currentUser != null
                        ? _formatDate(_currentUser!.updatedAt)
                        : 'Unknown',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Data is stored locally using SQLCipher encryption for security',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _refreshUserData();
                  },
                  child: const Text('Refresh Data'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('DEBUG: Error showing database stats: $e');
    }
  }

  void _showEditProfileDialog() {
    if (_currentUser != null) {
      showDialog(
        context: context,
        builder: (context) => EditProfileDialog(user: _currentUser!),
      ).then((result) {
        if (result == true) {
          // Profile was updated successfully, refresh the data
          _refreshUserData();
        }
      });
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text('Retry'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('DEBUG: Manual refresh requested');
                      _loadUserData();
                    },
                    child: const Text('Refresh'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      print('DEBUG: Testing authentication directly...');
                      try {
                        final isAuth = await _authRepository.isAuthenticated();
                        final user = await _authRepository.getCurrentUser();
                        print(
                          'DEBUG: Direct test - IsAuth: $isAuth, User: ${user?.email ?? 'null'}',
                        );
                      } catch (e) {
                        print('DEBUG: Direct test error: $e');
                      }
                    },
                    child: const Text('Test Auth'),
                  ),
                  ElevatedButton(
                    onPressed: _checkAuthStatus,
                    child: const Text('Check Auth'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      print('DEBUG: Checking secure storage directly...');
                      try {
                        final allKeys = await _secureStorage.getAllKeys();
                        print('DEBUG: All secure storage keys: $allKeys');

                        final hasToken = await _secureStorage.hasValidToken();
                        print('DEBUG: Has valid token: $hasToken');

                        if (hasToken) {
                          final tokenInfo = await _secureStorage.getTokenInfo();
                          print('DEBUG: Token info: $tokenInfo');
                        }
                      } catch (e) {
                        print('DEBUG: Secure storage check error: $e');
                      }
                    },
                    child: const Text('Check Storage'),
                  ),
                ],
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
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
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
                ),
                child: Stack(
                  children: [
                    // Action buttons positioned at top-right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _showEditProfileDialog,
                            icon: const Icon(Icons.edit, color: Colors.white),
                            tooltip: 'Edit Profile',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _refreshUserData,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            tooltip: 'Refresh Profile Data',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile content
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentUser!.displayName.isNotEmpty
                              ? _currentUser!.displayName
                              : _currentUser!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentUser!.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser!.role
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Database Information Card
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
                          Icon(Icons.storage, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Data Source Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Data Source',
                        'Local Database (SQLCipher Encrypted)',
                      ),
                      _buildInfoRow(
                        'Last Sync',
                        _formatDate(_currentUser!.updatedAt),
                      ),
                      _buildInfoRow('Database Status', 'Connected & Encrypted'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your profile data is securely stored locally and available offline',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showDatabaseStats,
                          icon: const Icon(Icons.analytics),
                          label: const Text('View Database Statistics'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(color: Colors.green[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Account Actions Card
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
                            Icons.settings,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Account Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: _navigateToChangePassword,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        title: 'Notification Settings',
                        subtitle: 'Manage your notification preferences',
                        onTap: () {
                          // TODO: Implement notification settings
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.security,
                        title: 'Privacy Settings',
                        subtitle: 'Control your privacy and data',
                        onTap: () {
                          // TODO: Implement privacy settings
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildThemeMenuButton(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeMenuButton() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: () {
            _showThemeMenu(context, themeProvider);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: Colors.grey[600], size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        themeProvider.getThemeModeName(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeMenu(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Choose Theme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.light,
                Icons.light_mode,
                'Light',
                'Use light theme',
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.dark,
                Icons.dark_mode,
                'Dark',
                'Use dark theme',
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.system,
                Icons.brightness_auto,
                'System',
                'Follow system theme',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _trySecureStorageFallback() async {
    try {
      print('DEBUG: Trying secure storage fallback...');
      final userId = await _secureStorage.getUserId();
      final userEmail = await _secureStorage.getUserEmail();

      print('DEBUG: Fallback data - User ID: $userId, Email: $userEmail');

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
      print('DEBUG: Fallback also failed: $e');
    }
  }
}
