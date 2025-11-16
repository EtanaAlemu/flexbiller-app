import 'package:flutter/material.dart';

/// Menu item configuration
class ActionMenuItem {
  final String value;
  final String label;
  final IconData icon;
  final bool isSectionHeader;
  final bool isDivider;

  const ActionMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isSectionHeader = false,
    this.isDivider = false,
  });

  /// Create a section header item
  const ActionMenuItem.sectionHeader(String label)
    : value = '',
      label = label,
      icon = Icons.label,
      isSectionHeader = true,
      isDivider = false;

  /// Create a divider
  const ActionMenuItem.divider()
    : value = '',
      label = '',
      icon = Icons.label,
      isSectionHeader = false,
      isDivider = true;
}

/// Base action menu widget that reduces code duplication
class BaseActionMenu extends StatelessWidget {
  final List<ActionMenuItem> menuItems;
  final Function(String action) onActionSelected;
  final IconData? icon;
  final String? tooltip;

  const BaseActionMenu({
    Key? key,
    required this.menuItems,
    required this.onActionSelected,
    this.icon,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: icon != null
          ? Icon(icon, color: colorScheme.onSurface)
          : Icon(Icons.more_vert, color: colorScheme.onSurface),
      tooltip: tooltip ?? 'More options',
      onSelected: onActionSelected,
      itemBuilder: (context) {
        final List<PopupMenuEntry<String>> items = [];
        for (final item in menuItems) {
          if (item.isDivider) {
            items.add(const PopupMenuDivider());
          } else if (item.isSectionHeader) {
            items.add(
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          } else {
            items.add(
              PopupMenuItem<String>(
                value: item.value,
                child: Row(
                  children: [
                    Icon(item.icon, color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text(item.label),
                  ],
                ),
              ),
            );
          }
        }
        return items;
      },
    );
  }

  /// Build standard filter & sort section items
  static List<ActionMenuItem> buildFilterSortSection({
    required String searchLabel,
    String? filterLabel,
    bool showFilter = true,
  }) {
    return [
      const ActionMenuItem.sectionHeader('FILTER & SORT'),
      ActionMenuItem(
        value: 'search',
        label: searchLabel,
        icon: Icons.search_rounded,
      ),
      if (showFilter && filterLabel != null)
        ActionMenuItem(
          value: 'filter',
          label: filterLabel,
          icon: Icons.filter_list_rounded,
        ),
      ActionMenuItem(
        value: 'sort',
        label: 'Sort Options',
        icon: Icons.sort_rounded,
      ),
      const ActionMenuItem.divider(),
    ];
  }

  /// Build standard actions section items
  static List<ActionMenuItem> buildActionsSection({
    required String exportLabel,
    bool showExport = true,
    bool showRefresh = true,
  }) {
    return [
      const ActionMenuItem.sectionHeader('ACTIONS'),
      if (showExport)
        ActionMenuItem(
          value: 'export',
          label: exportLabel,
          icon: Icons.download_rounded,
        ),
      if (showRefresh)
        ActionMenuItem(
          value: 'refresh',
          label: 'Refresh Data',
          icon: Icons.refresh_rounded,
        ),
      const ActionMenuItem.divider(),
    ];
  }

  /// Build standard settings section items
  static List<ActionMenuItem> buildSettingsSection({bool showViewMode = true}) {
    return [
      const ActionMenuItem.sectionHeader('SETTINGS'),
      if (showViewMode)
        ActionMenuItem(
          value: 'view_mode',
          label: 'View Mode',
          icon: Icons.view_module_rounded,
        ),
    ];
  }
}
