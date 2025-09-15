import 'package:flutter/material.dart';
import 'sidebar_menu.dart';
import 'dashboard_app_bar.dart';

class MobileDashboardLayout extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  final String pageTitle;
  final int currentPageIndex;
  final Widget content;
  final Function(int) onNavigate;
  final VoidCallback onLogout;
  final GlobalKey? accountsViewKey;

  const MobileDashboardLayout({
    Key? key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.pageTitle,
    required this.currentPageIndex,
    required this.content,
    required this.onNavigate,
    required this.onLogout,
    this.accountsViewKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            DashboardAppBar(
              isSidebarVisible: isSidebarVisible,
              onToggleSidebar: onToggleSidebar,
              pageTitle: pageTitle,
              currentPageIndex: currentPageIndex,
              accountsViewKey: accountsViewKey,
            ),
            Expanded(child: SafeArea(child: content)),
          ],
        ),
        if (isSidebarVisible)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              color: Theme.of(context).colorScheme.surface,
              child: SidebarMenu(
                selectedIndex: currentPageIndex,
                onItemSelected: onNavigate,
                onLogout: onLogout,
              ),
            ),
          ),
      ],
    );
  }
}
