import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/back_button_handler_widget.dart';
import '../../../../injection_container.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../accounts/presentation/bloc/accounts_list_bloc.dart';
import '../../../subscriptions/presentation/pages/subscriptions_demo_page.dart';
import '../../../tags/presentation/bloc/tags_bloc.dart';
import '../../../tags/presentation/pages/tags_page.dart';
import '../widgets/mobile_dashboard_layout.dart';
import '../widgets/desktop_dashboard_layout.dart';
import '../widgets/page_title_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _isSidebarVisible = true;
  bool _isMobile = false;
  final GlobalKey<AccountsViewState> _accountsViewKey =
      GlobalKey<AccountsViewState>();

  List<Widget> get _pages => [
    _DashboardContent(onNavigate: _switchTab),
    AccountsPage(accountsViewKey: _accountsViewKey),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<TagsBloc>()),
        BlocProvider(create: (context) => getIt<AccountsListBloc>()),
      ],
      child: DashboardNavigationHandler(
        currentIndex: _currentIndex,
        onNavigate: _navigateToPage,
        child: Scaffold(
          body: SafeArea(
            child: _isMobile
                ? MobileDashboardLayout(
                    isSidebarVisible: _isSidebarVisible,
                    onToggleSidebar: _toggleSidebar,
                    pageTitle: PageTitleHelper.getPageTitle(_currentIndex),
                    currentPageIndex: _currentIndex,
                    content: _pages[_currentIndex],
                    onNavigate: _navigateToPage,
                    onLogout: _handleLogout,
                    accountsViewKey: _accountsViewKey,
                  )
                : DesktopDashboardLayout(
                    isSidebarVisible: _isSidebarVisible,
                    onToggleSidebar: _toggleSidebar,
                    pageTitle: PageTitleHelper.getPageTitle(_currentIndex),
                    currentPageIndex: _currentIndex,
                    content: _pages[_currentIndex],
                    onNavigate: _navigateToPage,
                    onLogout: _handleLogout,
                    accountsViewKey: _accountsViewKey,
                  ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
      if (_isMobile) {
        _isSidebarVisible = false;
      }
    });
  }

  void _handleLogout() {
    // Handle logout - this will be handled by the auth bloc
    setState(() {
      if (_isMobile) {
        _isSidebarVisible = false;
      }
    });
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
