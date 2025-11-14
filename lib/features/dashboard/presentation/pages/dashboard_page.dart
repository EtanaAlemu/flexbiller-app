import 'package:flexbiller_app/features/accounts/presentation/bloc/accounts_orchestrator_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/back_button_handler_widget.dart';
import '../../../../injection_container.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../accounts/presentation/bloc/accounts_list_bloc.dart';
import '../../../subscriptions/presentation/pages/subscriptions_page.dart';
import '../../../subscriptions/presentation/bloc/subscriptions_bloc.dart';
import '../../../bundles/presentation/pages/bundles_page.dart';
import '../../../bundles/presentation/bloc/bundles_bloc.dart';
import '../../../bundles/presentation/bloc/bundle_multiselect_bloc.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../products/presentation/bloc/products_list_bloc.dart';
import '../../../plans/presentation/pages/plans_page.dart';
import '../../../plans/presentation/bloc/plans_bloc.dart';
import '../../../plans/presentation/bloc/plans_multiselect_bloc.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../payments/presentation/bloc/payment_multiselect_bloc.dart';
import '../../../invoices/presentation/pages/invoices_page.dart';
import '../../../invoices/presentation/bloc/invoices_bloc.dart';
import '../../../invoices/presentation/bloc/invoice_multiselect_bloc.dart';
import '../../../tags/presentation/bloc/tags_bloc.dart';
import '../../../tags/presentation/pages/tags_page.dart';
import '../../../tag_definitions/presentation/bloc/tag_definitions_bloc.dart';
import '../../../tag_definitions/presentation/pages/tag_definitions_page.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/page_title_helper.dart';
import 'dashboard_home_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _isSidebarVisible = false; // Always start with sidebar hidden on mobile
  final GlobalKey<AccountsViewState> _accountsViewKey =
      GlobalKey<AccountsViewState>();
  final GlobalKey<ProductsViewState> _productsViewKey =
      GlobalKey<ProductsViewState>();
  final GlobalKey<PaymentsViewState> _paymentsViewKey =
      GlobalKey<PaymentsViewState>();
  final GlobalKey<InvoicesViewState> _invoicesViewKey =
      GlobalKey<InvoicesViewState>();
  final GlobalKey<TagDefinitionsViewState> _tagDefinitionsViewKey =
      GlobalKey<TagDefinitionsViewState>();
  final GlobalKey _subscriptionsViewKey = GlobalKey();
  final GlobalKey _bundlesViewKey = GlobalKey();

  List<Widget> get _pages => [
    const DashboardHomePage(),
    AccountsPage(accountsViewKey: _accountsViewKey),
    SubscriptionsPage(key: _subscriptionsViewKey),
    BundlesPage(key: _bundlesViewKey),
    ProductsPage(productsViewKey: _productsViewKey),
    const PlansPage(),
    InvoicesView(key: _invoicesViewKey),
    PaymentsPage(paymentsViewKey: _paymentsViewKey),
    const _ReportsPage(),
    const TagsPage(),
    TagDefinitionsPage(tagDefinitionsViewKey: _tagDefinitionsViewKey),
    const SettingsPage(),
    const ProfilePage(),
  ];

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<TagsBloc>()),
        BlocProvider(create: (context) => getIt<TagDefinitionsBloc>()),
        BlocProvider(create: (context) => getIt<AccountsListBloc>()),
        BlocProvider(create: (context) => getIt<AccountsOrchestratorBloc>()),
        BlocProvider(create: (context) => getIt<BundlesBloc>()),
        BlocProvider(create: (context) => getIt<BundleMultiSelectBloc>()),
        BlocProvider(create: (context) => getIt<SubscriptionsBloc>()),
        BlocProvider(create: (context) => getIt<ProductsListBloc>()),
        BlocProvider(create: (context) => getIt<PlansBloc>()),
        BlocProvider(create: (context) => getIt<PlansMultiSelectBloc>()),
        BlocProvider(create: (context) => getIt<PaymentsBloc>()),
        BlocProvider(create: (context) => getIt<PaymentMultiSelectBloc>()),
        BlocProvider(create: (context) => getIt<InvoicesBloc>()),
        BlocProvider(create: (context) => getIt<InvoiceMultiSelectBloc>()),
      ],
      child: DashboardNavigationHandler(
        currentIndex: _currentIndex,
        onNavigate: _navigateToPage,
        child: Scaffold(
          body: SafeArea(
            child: DashboardLayout(
              isSidebarVisible: _isSidebarVisible,
              onToggleSidebar: _toggleSidebar,
              pageTitle: PageTitleHelper.getPageTitle(_currentIndex),
              currentPageIndex: _currentIndex,
              content: _pages[_currentIndex],
              onNavigate: _navigateToPage,
              onLogout: _handleLogout,
              accountsViewKey: _accountsViewKey,
              productsViewKey: _productsViewKey,
              paymentsViewKey: _paymentsViewKey,
              invoicesViewKey: _invoicesViewKey,
              tagDefinitionsViewKey: _tagDefinitionsViewKey,
              subscriptionsViewKey: _subscriptionsViewKey,
              bundlesViewKey: _bundlesViewKey,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
      _isSidebarVisible =
          false; // Always hide sidebar after navigation on mobile
    });
  }

  void _handleLogout() {
    // Handle logout - this will be handled by the auth bloc
    setState(() {
      _isSidebarVisible = false; // Always hide sidebar after logout on mobile
    });
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
