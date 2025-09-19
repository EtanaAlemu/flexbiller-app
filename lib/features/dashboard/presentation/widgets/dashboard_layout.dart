import 'dart:ui';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        if (isSidebarVisible) ...[
          // Background overlay with blur effect
          Positioned.fill(
            child: GestureDetector(
              onTap: onToggleSidebar,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                color: Colors.black.withOpacity(0.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          // Sidebar menu with slide animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isSidebarVisible
                ? 0
                : -MediaQuery.of(context).size.width * 0.8,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFFAFAFA),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SidebarMenu(
                selectedIndex: currentPageIndex,
                onItemSelected: (index) {
                  // Handle navigation - this will be handled by parent
                },
                onLogout: () {
                  // Handle logout - this will be handled by parent
                },
                onClose: onToggleSidebar, // Close sidebar for special actions
              ),
            ),
          ),
        ],
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
