import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CacheService _cacheService = getIt<CacheService>();
  bool _isClearingCache = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your app experience',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Settings
            _buildSettingsSection(
              context,
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [_buildThemeSelector(context)],
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSettingsSection(
              context,
              title: 'Account',
              icon: Icons.account_circle_outlined,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _navigateToChangePassword,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notifications Settings
            _buildSettingsSection(
              context,
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Manage email notification preferences',
                  trailing: Switch(
                    value: true, // This would come from user preferences
                    onChanged: (value) {
                      // TODO: Implement email notification toggle
                    },
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.push_pin_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications on your device',
                  trailing: Switch(
                    value: false, // This would come from user preferences
                    onChanged: (value) {
                      // TODO: Implement push notification toggle
                    },
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.schedule_outlined,
                  title: 'Reminder Notifications',
                  subtitle: 'Get reminded about important tasks',
                  trailing: Switch(
                    value: true, // This would come from user preferences
                    onChanged: (value) {
                      // TODO: Implement reminder notification toggle
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy & Security Settings
            _buildSettingsSection(
              context,
              title: 'Privacy & Security',
              icon: Icons.security_outlined,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Data Visibility',
                  subtitle: 'Control who can see your data',
                  onTap: () {
                    // TODO: Implement data visibility settings
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.storage_outlined,
                  title: 'Data Storage',
                  subtitle: 'Manage your local data storage',
                  onTap: () {
                    // TODO: Implement data storage settings
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.storage_outlined,
                  title: 'Clear Cache',
                  subtitle: _isClearingCache
                      ? 'Clearing cache...'
                      : 'Clear app cache and temporary data',
                  onTap: _isClearingCache ? null : _showClearCacheDialog,
                  trailing: _isClearingCache
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About Settings
            _buildSettingsSection(
              context,
              title: 'About',
              icon: Icons.info_outline,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    // TODO: Implement help and support
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'View terms and conditions',
                  onTap: () {
                    // TODO: Implement terms of service
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  onTap: () {
                    // TODO: Implement privacy policy
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: '1.0.0 (Build 1)',
                  onTap: null, // No action for version info
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? Colors.red
                  : isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
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
                      color: isDestructive
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red.withValues(alpha: 0.7)
                          : isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing,
            ] else if (onTap != null) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark
                    ? const Color(0xFF4B5563)
                    : const Color(0xFF9CA3AF),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            _buildSettingsTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: themeProvider.getThemeModeName(),
              onTap: () => _showThemeMenu(context, themeProvider),
            ),
          ],
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

  void _navigateToChangePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
  }

  void _showClearCacheDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.storage_outlined, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            const Text('Clear Cache'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose what to clear:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildCacheOption(
              icon: Icons.apps_outlined,
              title: 'App Cache Only',
              subtitle: 'Clear temporary files and app cache',
              onTap: () {
                Navigator.of(dialogContext).pop();
                _clearAppCache();
              },
            ),
            const SizedBox(height: 12),
            _buildCacheOption(
              icon: Icons.person_outline,
              title: 'User Data Only',
              subtitle: 'Clear user data and authentication tokens',
              onTap: () {
                Navigator.of(dialogContext).pop();
                _clearUserData();
              },
            ),
            const SizedBox(height: 12),
            _buildCacheOption(
              icon: Icons.delete_sweep_outlined,
              title: 'Everything',
              subtitle: 'Clear all cache and user data',
              onTap: () {
                Navigator.of(dialogContext).pop();
                _clearAllCache();
              },
              isDestructive: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDestructive
                          ? Colors.red.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAppCache() async {
    if (_isClearingCache) return;

    setState(() {
      _isClearingCache = true;
    });

    try {
      final result = await _cacheService.clearAppCache();
      _showCacheResult(result);
    } catch (e) {
      _showCacheError('Failed to clear app cache: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClearingCache = false;
        });
      }
    }
  }

  Future<void> _clearUserData() async {
    if (_isClearingCache) return;

    setState(() {
      _isClearingCache = true;
    });

    try {
      final result = await _cacheService.clearUserData();
      _showCacheResult(result);
    } catch (e) {
      _showCacheError('Failed to clear user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClearingCache = false;
        });
      }
    }
  }

  Future<void> _clearAllCache() async {
    if (_isClearingCache) return;

    setState(() {
      _isClearingCache = true;
    });

    try {
      final result = await _cacheService.clearAllCache();
      _showCacheResult(result);
    } catch (e) {
      _showCacheError('Failed to clear all cache: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClearingCache = false;
        });
      }
    }
  }

  void _showCacheResult(CacheClearResult result) {
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    result.message,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (result.clearedItems.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Cleared: ${result.clearedItems.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      _showCacheError(result.errors.join('\n'));
    }
  }

  void _showCacheError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
