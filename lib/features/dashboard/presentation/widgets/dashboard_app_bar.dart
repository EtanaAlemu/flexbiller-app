import 'package:flutter/material.dart';
import 'accounts_action_menu.dart';
import 'products_action_menu.dart';
import 'payments_action_menu.dart';
import 'tag_definitions_action_menu.dart';
import '../../../tag_definitions/presentation/pages/tag_definitions_page.dart';

class DashboardAppBar extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  final String pageTitle;
  final int currentPageIndex;
  final GlobalKey? accountsViewKey;
  final GlobalKey? productsViewKey;
  final GlobalKey? paymentsViewKey;
  final GlobalKey<TagDefinitionsViewState>? tagDefinitionsViewKey;

  const DashboardAppBar({
    Key? key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.pageTitle,
    required this.currentPageIndex,
    this.accountsViewKey,
    this.productsViewKey,
    this.paymentsViewKey,
    this.tagDefinitionsViewKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggleSidebar,
            icon: Icon(isSidebarVisible ? Icons.menu_open : Icons.menu),
            tooltip: isSidebarVisible ? 'Hide sidebar' : 'Show sidebar',
          ),
          const SizedBox(width: 16),
          Text(
            pageTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // Accounts-specific actions
          if (currentPageIndex == 1) // Accounts page
            Row(
              children: [
                IconButton(
                  onPressed: () => _toggleSearchBar(),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search Accounts',
                ),
                AccountsActionMenu(accountsViewKey: accountsViewKey),
              ],
            ),
          // Products-specific actions
          if (currentPageIndex == 3) // Products page
            Row(
              children: [
                IconButton(
                  onPressed: () => _toggleProductsSearchBar(),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search Products',
                ),
                ProductsActionMenu(productsViewKey: productsViewKey),
              ],
            ),
          // Payments-specific actions
          if (currentPageIndex == 6) // Payments page
            Row(
              children: [
                IconButton(
                  onPressed: () => _togglePaymentsSearchBar(),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search Payments',
                ),
                PaymentsActionMenu(paymentsViewKey: paymentsViewKey),
              ],
            ),
          // Tag Definitions-specific actions
          if (currentPageIndex == 9) // Tag Definitions page
            Row(
              children: [
                IconButton(
                  onPressed: () => _toggleTagDefinitionsSearchBar(),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search Tag Definitions',
                ),
                TagDefinitionsActionMenu(
                  tagDefinitionsViewKey: tagDefinitionsViewKey,
                ),
              ],
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _toggleSearchBar() {
    if (accountsViewKey?.currentState != null) {
      (accountsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _toggleProductsSearchBar() {
    if (productsViewKey?.currentState != null) {
      (productsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _togglePaymentsSearchBar() {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _toggleTagDefinitionsSearchBar() {
    if (tagDefinitionsViewKey?.currentState != null) {
      (tagDefinitionsViewKey!.currentState as TagDefinitionsViewState)
          .toggleSearchBar();
    }
  }
}
