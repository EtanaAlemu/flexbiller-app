import 'package:flutter/material.dart';
import 'sidebar_menu.dart';
import 'dashboard_app_bar.dart';

class DesktopDashboardLayout extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  final String pageTitle;
  final int currentPageIndex;
  final Widget content;
  final Function(int) onNavigate;
  final VoidCallback onLogout;
  final GlobalKey? accountsViewKey;
  final GlobalKey? productsViewKey;

  const DesktopDashboardLayout({
    Key? key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.pageTitle,
    required this.currentPageIndex,
    required this.content,
    required this.onNavigate,
    required this.onLogout,
    this.accountsViewKey,
    this.productsViewKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSidebarVisible)
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.surface,
            child: SidebarMenu(
              selectedIndex: currentPageIndex,
              onItemSelected: onNavigate,
              onLogout: onLogout,
              onClose:
                  onToggleSidebar, // Close sidebar after any menu selection
            ),
          ),
        Expanded(
          child: Column(
            children: [
              DashboardAppBar(
                isSidebarVisible: isSidebarVisible,
                onToggleSidebar: onToggleSidebar,
                pageTitle: pageTitle,
                currentPageIndex: currentPageIndex,
                accountsViewKey: accountsViewKey,
                productsViewKey: productsViewKey,
              ),
              Expanded(child: SafeArea(child: content)),
            ],
          ),
        ),
      ],
    );
  }
}
