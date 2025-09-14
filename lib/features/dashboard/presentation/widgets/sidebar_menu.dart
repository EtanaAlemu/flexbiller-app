import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SidebarMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onLogout;

  const SidebarMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
  }) : super(key: key);

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  bool _isExpanded = true;

  final List<SidebarMenuItem> _menuItems = [
    SidebarMenuItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      index: 0,
      isExpanded: true,
    ),
    SidebarMenuItem(
      icon: Icons.account_balance,
      title: 'Accounts',
      index: 1,
      isExpanded: true,
    ),
    SidebarMenuItem(
      icon: Icons.subscriptions,
      title: 'Subscriptions',
      index: 2,
      isExpanded: true,
    ),
    SidebarMenuItem(
      icon: Icons.receipt_long,
      title: 'Invoices',
      index: 3,
      isExpanded: false,
    ),
    SidebarMenuItem(
      icon: Icons.payment,
      title: 'Payments',
      index: 4,
      isExpanded: false,
    ),
    SidebarMenuItem(
      icon: Icons.analytics,
      title: 'Reports',
      index: 5,
      isExpanded: true,
    ),
    SidebarMenuItem(
      icon: Icons.label,
      title: 'Tags',
      index: 6,
      isExpanded: true,
    ),
    SidebarMenuItem(
      icon: Icons.settings,
      title: 'Settings',
      index: 7,
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(child: _buildMenuItems(context)),
          const Divider(height: 1),
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FlexBiller',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Billing Management',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: _isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildMenuItem(context, item);
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, SidebarMenuItem item) {
    final isSelected = widget.selectedIndex == item.index;
    final isAvailable = item.isExpanded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isAvailable
              ? () => widget.onItemSelected(item.index)
              : () => _showComingSoonSnackBar(context, item.title),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isAvailable
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isAvailable
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isExpanded) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        _getUserInitials(state),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getUserName(state),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getUserEmail(state),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _getUserInitials(state),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (_isExpanded) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showProfileDialog(context, state),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(
                      _isExpanded ? Icons.logout : Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUserInitials(AuthState state) {
    if (state is LoginSuccess) {
      final name = state.user.name ?? '';
      if (name.isNotEmpty) {
        final parts = name.split(' ');
        if (parts.length >= 2) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }
        return parts[0][0].toUpperCase();
      }
    } else if (state is AuthSuccess) {
      final name = state.user.name ?? '';
      if (name.isNotEmpty) {
        final parts = name.split(' ');
        if (parts.length >= 2) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }
        return parts[0][0].toUpperCase();
      }
    }
    return 'U';
  }

  String _getUserName(AuthState state) {
    if (state is LoginSuccess) {
      return state.user.name ?? 'User';
    } else if (state is AuthSuccess) {
      return state.user.name ?? 'User';
    }
    return 'User';
  }

  String _getUserEmail(AuthState state) {
    if (state is LoginSuccess) {
      return state.user.email ?? '';
    } else if (state is AuthSuccess) {
      return state.user.email ?? '';
    }
    return '';
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state is LoginSuccess) ...[
              _buildProfileField('Name', state.user.name ?? 'N/A'),
              _buildProfileField('Email', state.user.email ?? 'N/A'),
              _buildProfileField('Role', state.user.role ?? 'N/A'),
              _buildProfileField('Phone', state.user.phone ?? 'N/A'),
            ] else if (state is AuthSuccess) ...[
              _buildProfileField('Name', state.user.name ?? 'N/A'),
              _buildProfileField('Email', state.user.email ?? 'N/A'),
              _buildProfileField('Role', state.user.role ?? 'N/A'),
              _buildProfileField('Phone', state.user.phone ?? 'N/A'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Get the AuthBloc from the parent context before showing the dialog
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authBloc.add(LogoutRequested());
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Colors.white,
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
  final String title;
  final int index;
  final bool isExpanded;

  const SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.isExpanded,
  });
}
