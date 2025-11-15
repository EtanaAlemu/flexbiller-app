import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';

class SidebarMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onLogout;
  final VoidCallback? onClose;

  const SidebarMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
    this.onClose,
  }) : super(key: key);

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
    with TickerProviderStateMixin {
  bool _isExpanded = true; // Always expanded for mobile
  late AnimationController _expandController;
  late AnimationController _fadeController;

  // Track which categories are expanded
  final Map<String, bool> _categoryExpanded = {
    'Catalog': false,
    'Billing': false,
    'CRM': false,
    'User Management': false,
  };

  // Top-level menu items (not in categories)
  final List<SidebarMenuItem> _topLevelItems = [
    SidebarMenuItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      title: 'Dashboard',
      index: 0,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      title: 'Reports',
      index: 8,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      title: 'Tag Definitions',
      index: 10,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      title: 'Settings',
      index: 11,
      isAvailable: true,
      badge: null,
    ),
  ];

  // Catalog category items
  final List<SidebarMenuItem> _catalogItems = [
    SidebarMenuItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance,
      title: 'Accounts',
      index: 1,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      title: 'Products',
      index: 4,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium,
      title: 'Price Plans',
      index: 5,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.label_outlined,
      activeIcon: Icons.label,
      title: 'Tags',
      index: 9,
      isAvailable: true,
      badge: null,
    ),
  ];

  // Billing category items
  final List<SidebarMenuItem> _billingItems = [
    SidebarMenuItem(
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      title: 'Payments',
      index: 7,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      title: 'Invoices',
      index: 6,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.subscriptions_outlined,
      activeIcon: Icons.subscriptions,
      title: 'Subscriptions',
      index: 2,
      isAvailable: true,
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      title: 'Bundles',
      index: 3,
      isAvailable: true,
      badge: null,
    ),
  ];

  // CRM category items
  final List<SidebarMenuItem> _crmItems = [
    SidebarMenuItem(
      icon: Icons.contacts_outlined,
      activeIcon: Icons.contacts,
      title: 'Contacts',
      index: 14,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      title: 'Opportunities',
      index: 15,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note,
      title: 'Activities',
      index: 16,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
  ];

  // User Management category items
  final List<SidebarMenuItem> _userManagementItems = [
    SidebarMenuItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      title: 'Users',
      index: 17,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      title: 'Roles',
      index: 18,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
    SidebarMenuItem(
      icon: Icons.security_outlined,
      activeIcon: Icons.security,
      title: 'Permissions',
      index: 19,
      isAvailable: false, // Placeholder - will create page later
      badge: null,
    ),
  ];

  // Profile and Logout items
  final List<SidebarMenuItem> _bottomItems = [
    SidebarMenuItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      title: 'Profile',
      index: 12,
      isAvailable: true,
      badge: null,
      isSpecial: false,
    ),
    SidebarMenuItem(
      icon: Icons.logout_outlined,
      activeIcon: Icons.logout_rounded,
      title: 'Logout',
      index: 13,
      isAvailable: true,
      badge: null,
      isSpecial: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(child: _buildMenuItems(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FlexBiller',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Billing Management',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      children: [
        // Top-level items
        ..._topLevelItems.map((item) => _buildMenuItem(context, item)),

        const SizedBox(height: 8),

        // Catalog category
        _buildCategory(
          context,
          'Catalog',
          Icons.inventory_2_outlined,
          _catalogItems,
        ),

        // Billing category
        _buildCategory(
          context,
          'Billing',
          Icons.payment_outlined,
          _billingItems,
        ),

        // CRM category
        _buildCategory(
          context,
          'CRM',
          Icons.business_center_outlined,
          _crmItems,
        ),

        // User Management category
        _buildCategory(
          context,
          'User Management',
          Icons.people_outline,
          _userManagementItems,
        ),

        const SizedBox(height: 8),

        // Bottom items (Profile and Logout)
        ..._bottomItems.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String categoryName,
    IconData categoryIcon,
    List<SidebarMenuItem> items,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpanded = _categoryExpanded[categoryName] ?? true;
    final hasSelectedItem = items.any(
      (item) => widget.selectedIndex == item.index,
    );

    return Column(
      children: [
        // Category header
        InkWell(
          onTap: () {
            setState(() {
              _categoryExpanded[categoryName] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: hasSelectedItem
                  ? (isDark
                        ? const Color(0xFF1E3A8A).withOpacity(0.15)
                        : const Color(0xFF3B82F6).withOpacity(0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  categoryIcon,
                  size: 20,
                  color: hasSelectedItem
                      ? (isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF3B82F6))
                      : (isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasSelectedItem
                          ? (isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF3B82F6))
                          : (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280)),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category items (expandable)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _buildMenuItem(context, item, isSubItem: true),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    SidebarMenuItem item, {
    bool isSubItem = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = widget.selectedIndex == item.index;
    final isAvailable = item.isAvailable;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: isSubItem ? 8 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                  ? const Color(0xFF1E3A8A).withOpacity(0.2)
                  : const Color(0xFF3B82F6).withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: isDark
                    ? const Color(0xFF1E3A8A).withOpacity(0.3)
                    : const Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isAvailable
              ? () {
                  if (item.isSpecial) {
                    if (item.title == 'Logout') {
                      _showLogoutDialog(context);
                    }
                    // Close sidebar after special actions
                    widget.onClose?.call();
                  } else {
                    widget.onItemSelected(item.index);
                    // Navigation will handle sidebar closing
                  }
                }
              : () => _showComingSoonSnackBar(context, item.title),
          borderRadius: BorderRadius.circular(12),
          splashColor: isDark
              ? Colors.white.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: isDark
              ? Colors.white.withOpacity(0.05)
              : theme.colorScheme.primary.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSubItem ? 12 : 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                if (isSubItem) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF3B82F6))
                          : (isDark
                                ? const Color(0xFF4B5563)
                                : const Color(0xFF9CA3AF)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey('${item.index}_${isSelected}'),
                    size: isSubItem ? 20 : 22,
                    color: item.isSpecial
                        ? (isDark
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626))
                        : isSelected
                        ? (isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF3B82F6))
                        : isAvailable
                        ? (isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280))
                        : (isDark
                              ? const Color(0xFF4B5563)
                              : const Color(0xFF9CA3AF)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: item.isSpecial
                                ? (isDark
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFDC2626))
                                : isSelected
                                ? (isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF3B82F6))
                                : isAvailable
                                ? (isDark
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF1F2937))
                                : (isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFF9CA3AF)),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: isSubItem ? 13 : 14,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      if (item.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF4B5563)
                                  : const Color(0xFFD1D5DB),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.badge!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    CustomSnackBar.showComingSoon(context, feature: feature);
  }

  void _showLogoutDialog(BuildContext context) {
    // Get the AuthBloc from the parent context before showing the dialog
    final authBloc = context.read<AuthBloc>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: const Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authBloc.add(LogoutRequested());
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class SidebarMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final int index;
  final bool isAvailable;
  final String? badge;
  final bool isSpecial;

  const SidebarMenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.index,
    required this.isAvailable,
    this.badge,
    this.isSpecial = false,
  });
}
