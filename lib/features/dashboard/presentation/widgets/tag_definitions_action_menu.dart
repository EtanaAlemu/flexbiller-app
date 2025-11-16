import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tag_definitions/presentation/pages/tag_definitions_page.dart';
import '../../../tag_definitions/presentation/bloc/tag_definitions_bloc.dart';
import '../../../tag_definitions/presentation/bloc/tag_definitions_event.dart';
import '../../../tag_definitions/presentation/bloc/tag_definitions_state.dart';
import '../../../tag_definitions/presentation/widgets/export_tag_definitions_dialog.dart';
import '../../../tag_definitions/domain/entities/tag_definition.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/sort_options_bottom_sheet.dart';
import '../../../../core/widgets/view_mode_dialog.dart';
import '../../../../core/widgets/base_action_menu.dart';

class TagDefinitionsActionMenu extends StatelessWidget {
  final GlobalKey<TagDefinitionsViewState>? tagDefinitionsViewKey;

  const TagDefinitionsActionMenu({Key? key, this.tagDefinitionsViewKey})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ...BaseActionMenu.buildFilterSortSection(
        searchLabel: 'Search Tag Definitions',
        filterLabel: 'Filter by Type',
      ),
      ...BaseActionMenu.buildActionsSection(exportLabel: 'Export All'),
      ...BaseActionMenu.buildSettingsSection(),
    ];

    return BaseActionMenu(
      menuItems: menuItems,
      onActionSelected: (value) => _handleMenuAction(context, value),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'search':
        _toggleSearchBar(context);
        break;
      case 'filter':
        _showFilterOptions(context);
        break;
      case 'sort':
        _showSortOptions(context);
        break;
      case 'export':
        _exportTagDefinitions(context);
        break;
      case 'refresh':
        _refreshTagDefinitions(context);
        break;
      case 'view_mode':
        _showViewModeOptions(context);
        break;
    }
  }

  void _toggleSearchBar(BuildContext context) {
    if (tagDefinitionsViewKey?.currentState != null) {
      (tagDefinitionsViewKey!.currentState as TagDefinitionsViewState)
          .toggleSearchBar();
    }
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tag Definitions'),
        content: const Text('Filter options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    SortOptionsBottomSheet.show(
      context,
      title: 'Sort Tag Definitions',
      options: const [
        SortOption(
          title: 'Name (A-Z)',
          sortBy: 'name',
          sortOrder: 'asc',
          icon: Icons.sort_by_alpha,
        ),
        SortOption(
          title: 'Name (Z-A)',
          sortBy: 'name',
          sortOrder: 'desc',
          icon: Icons.sort_by_alpha,
        ),
        SortOption(
          title: 'Created Date (Newest)',
          sortBy: 'createdAt',
          sortOrder: 'desc',
          icon: Icons.calendar_today,
        ),
        SortOption(
          title: 'Created Date (Oldest)',
          sortBy: 'createdAt',
          sortOrder: 'asc',
          icon: Icons.calendar_today,
        ),
        SortOption(
          title: 'Type (Control First)',
          sortBy: 'type',
          sortOrder: 'asc',
          icon: Icons.label,
        ),
        SortOption(
          title: 'Type (Regular First)',
          sortBy: 'type',
          sortOrder: 'desc',
          icon: Icons.label,
        ),
      ],
      onSortSelected: (sortBy, sortOrder) {
        _applySort(context, sortBy, sortOrder);
      },
    );
  }

  void _applySort(BuildContext context, String sortBy, String sortOrder) {
    // Reload tag definitions - sorting will be handled by the repository/use case
    context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
    CustomSnackBar.showSuccess(
      context,
      message: 'Tag definitions sorted by ${sortBy} ($sortOrder)',
    );
  }

  Future<void> _exportTagDefinitions(BuildContext context) async {
    try {
      // Get all tag definitions from the bloc state
      final bloc = context.read<TagDefinitionsBloc>();
      final state = bloc.state;

      List<TagDefinition> allTagDefinitions = [];

      if (state is TagDefinitionsLoaded) {
        allTagDefinitions = state.tagDefinitions;
      } else if (state is TagDefinitionsSearchResults) {
        allTagDefinitions = state.searchResults;
      } else if (state is TagDefinitionsWithSelection) {
        allTagDefinitions = state.tagDefinitions;
      } else {
        // If no data loaded, trigger a load first
        bloc.add(LoadTagDefinitions());
        CustomSnackBar.showInfo(
          context,
          message: 'Loading tag definitions... Please try again.',
        );
        return;
      }

      if (allTagDefinitions.isEmpty) {
        CustomSnackBar.showInfo(
          context,
          message: 'No tag definitions to export',
        );
        return;
      }

      // Show export dialog
      final result = await showDialog(
        context: context,
        builder: (context) => ExportTagDefinitionsDialog(
          selectedTagDefinitions: allTagDefinitions,
        ),
      );

      if (result != null) {
        final selectedFormat = result['format'] as String;
        // Dispatch export event to BLoC
        bloc.add(ExportSelectedTagDefinitions(selectedFormat));
      }
    } catch (e) {
      CustomSnackBar.showError(
        context,
        message: 'Failed to export tag definitions: $e',
      );
    }
  }

  void _refreshTagDefinitions(BuildContext context) {
    // Dispatch refresh event to BLoC
    context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
    CustomSnackBar.showSuccess(
      context,
      message: 'Refreshing tag definitions...',
    );
  }

  void _showViewModeOptions(BuildContext context) {
    ViewModeDialog.show(
      context,
      title: 'View Mode',
      onModeSelected: (mode) {
        final modeName = mode == ViewMode.list ? 'List' : 'Grid';
        CustomSnackBar.showSuccess(
          context,
          message: 'View mode changed to $modeName',
        );
      },
    );
  }
}
