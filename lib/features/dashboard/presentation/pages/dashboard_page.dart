import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../subscriptions/presentation/pages/subscriptions_demo_page.dart';
import '../../../tags/presentation/bloc/tags_bloc.dart';
import '../../../tags/presentation/pages/tags_page.dart';
import '../widgets/sidebar_menu.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _isSidebarVisible = true;
  bool _isMobile = false;

  List<Widget> get _pages => [
    _DashboardContent(onNavigate: _switchTab),
    const AccountsPage(),
    const SubscriptionsDemoPage(),
    const _InvoicesPage(),
    const _PaymentsPage(),
    const _ReportsPage(),
    const TagsPage(),
    const _SettingsPage(),
  ];

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MediaQuery.of(context).size.width < 768;
    if (_isMobile) {
      _isSidebarVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TagsBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: _isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Mobile App Bar
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleSidebar,
                    icon: const Icon(Icons.menu),
                    tooltip: 'Show sidebar',
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getPageTitle(_currentIndex),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Mobile bottom navigation
                  IconButton(
                    onPressed: () => _showBottomSheet(context),
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More options',
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(child: SafeArea(child: _pages[_currentIndex])),
            // Mobile Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance),
                    label: 'Accounts',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.subscriptions),
                    label: 'Subscriptions',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: 'Reports',
                  ),
                ],
              ),
            ),
          ],
        ),
        // Mobile Sidebar Backdrop
        if (_isSidebarVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarVisible = false;
                });
              },
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        // Mobile Sidebar Overlay
        if (_isSidebarVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: SidebarMenu(
                  selectedIndex: _currentIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isSidebarVisible = false;
                    });
                  },
                  onLogout: () {
                    // Handle logout - this will be handled by the auth bloc
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        if (_isSidebarVisible)
          SafeArea(
            child: SidebarMenu(
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onLogout: () {
                // Handle logout - this will be handled by the auth bloc
              },
            ),
          ),
        Expanded(
          child: Column(
            children: [
              // Top App Bar
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (!_isSidebarVisible)
                      IconButton(
                        onPressed: _toggleSidebar,
                        icon: const Icon(Icons.menu),
                        tooltip: 'Show sidebar',
                      ),
                    const SizedBox(width: 16),
                    Text(
                      _getPageTitle(_currentIndex),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _toggleSidebar,
                      icon: Icon(
                        _isSidebarVisible ? Icons.menu_open : Icons.menu,
                      ),
                      tooltip: _isSidebarVisible
                          ? 'Hide sidebar'
                          : 'Show sidebar',
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              // Main Content
              Expanded(child: SafeArea(child: _pages[_currentIndex])),
            ],
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Invoices'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payments'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Tags'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 6);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 7);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Accounts';
      case 2:
        return 'Subscriptions';
      case 3:
        return 'Invoices';
      case 4:
        return 'Payments';
      case 5:
        return 'Reports';
      case 6:
        return 'Tags';
      case 7:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }
}

class _DashboardContent extends StatelessWidget {
  final Function(int) onNavigate;

  const _DashboardContent({Key? key, required this.onNavigate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to FlexBiller',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your billing and accounts efficiently',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320, // Increased height to prevent overflow
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1, // Adjusted aspect ratio for better fit
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.account_balance,
                  title: 'Accounts',
                  subtitle: 'Manage customer accounts',
                  color: AppTheme.getSuccessColor(Theme.of(context).brightness),
                  onTap: () {
                    // Navigate to accounts tab (index 1)
                    onNavigate(1);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Billing',
                  subtitle: 'Create and manage invoices',
                  color: Colors.blue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Billing feature - Coming Soon!'),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.payment,
                  title: 'Payments',
                  subtitle: 'Track payment transactions',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payments feature - Coming Soon!'),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Reports',
                  subtitle: 'View business analytics',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to reports tab (index 5)
                    onNavigate(5);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color), // Reduced icon size
              const SizedBox(height: 6), // Reduced spacing
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), // Smaller text
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 3), // Reduced spacing
              Flexible(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 11, // Smaller font size
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoicesPage extends StatelessWidget {
  const _InvoicesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Invoices Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Invoice management features\nwill be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PaymentsPage extends StatelessWidget {
  const _PaymentsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Payments Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Payment processing features\nwill be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ReportsPage extends StatelessWidget {
  const _ReportsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Reports Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Business analytics and reporting features\nwill be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Settings Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Application settings and preferences\nwill be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
