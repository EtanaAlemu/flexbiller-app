import 'package:flexbiller_app/features/accounts/presentation/bloc/accounts_orchestrator_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/back_button_handler_widget.dart';
import '../../../../injection_container.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../accounts/presentation/bloc/accounts_list_bloc.dart';
import '../../../subscriptions/presentation/pages/subscriptions_demo_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../products/presentation/bloc/products_list_bloc.dart';
import '../../../plans/presentation/pages/plans_page.dart';
import '../../../plans/presentation/bloc/plans_bloc.dart';
import '../../../tags/presentation/bloc/tags_bloc.dart';
import '../../../tags/presentation/pages/tags_page.dart';
import '../widgets/mobile_dashboard_layout.dart';
import '../widgets/desktop_dashboard_layout.dart';
import '../widgets/page_title_helper.dart';
import 'dashboard_demo_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

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
  final GlobalKey<ProductsViewState> _productsViewKey =
      GlobalKey<ProductsViewState>();

  List<Widget> get _pages => [
    const DashboardDemoPage(),
    AccountsPage(accountsViewKey: _accountsViewKey),
    const SubscriptionsDemoPage(),
    ProductsPage(productsViewKey: _productsViewKey),
    const PlansPage(),
    const _InvoicesPage(),
    const _PaymentsPage(),
    const _ReportsPage(),
    const TagsPage(),
    const SettingsPage(),
    const ProfilePage(),
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
        BlocProvider(create: (context) => getIt<AccountsOrchestratorBloc>()),
        BlocProvider(create: (context) => getIt<ProductsListBloc>()),
        BlocProvider(create: (context) => getIt<PlansBloc>()),
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
                    productsViewKey: _productsViewKey,
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
                    productsViewKey: _productsViewKey,
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
