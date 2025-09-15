import 'package:flutter/material.dart';
import 'sidebar_menu.dart';
import 'dashboard_app_bar.dart';

class DashboardLayout extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  final String pageTitle;
  final int currentPageIndex;
  final Widget content;
  final bool isMobile;

  const DashboardLayout({
    Key? key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.pageTitle,
    required this.currentPageIndex,
    required this.content,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            DashboardAppBar(
              isSidebarVisible: isSidebarVisible,
              onToggleSidebar: onToggleSidebar,
              pageTitle: pageTitle,
              currentPageIndex: currentPageIndex,
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
                onItemSelected: (index) {
                  // Handle navigation
                },
                onLogout: () {
                  // Handle logout
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        if (isSidebarVisible)
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.surface,
            child: SidebarMenu(
              selectedIndex: currentPageIndex,
              onItemSelected: (index) {
                // Handle navigation
              },
              onLogout: () {
                // Handle logout
              },
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
              ),
              Expanded(child: SafeArea(child: content)),
            ],
          ),
        ),
      ],
    );
  }
}
