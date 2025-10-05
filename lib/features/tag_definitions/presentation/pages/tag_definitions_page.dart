import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../../domain/entities/tag_definition.dart';
import '../widgets/tag_definition_card_widget.dart';
import '../widgets/selectable_tag_definition_card_widget.dart';
import '../widgets/tag_definitions_multi_select_action_bar.dart';
import 'create_tag_definition_page.dart';

class TagDefinitionsPage extends StatefulWidget {
  final GlobalKey<TagDefinitionsViewState>? tagDefinitionsViewKey;

  const TagDefinitionsPage({super.key, this.tagDefinitionsViewKey});

  @override
  State<TagDefinitionsPage> createState() => _TagDefinitionsPageState();
}

class _TagDefinitionsPageState extends State<TagDefinitionsPage> {
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      final isScrollingDown = currentOffset > _lastScrollOffset;
      final isScrollingUp = currentOffset < _lastScrollOffset;

      // Hide FAB when scrolling down
      if (isScrollingDown && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
      // Show FAB when scrolling up
      else if (isScrollingUp && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }

      _lastScrollOffset = currentOffset;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load tag definitions when the page is built (only if not already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<TagDefinitionsBloc>();
      if (bloc.state is TagDefinitionsInitial) {
        bloc.add(LoadTagDefinitions());
      }
    });

    return BlocListener<TagDefinitionsBloc, TagDefinitionsState>(
      listener: (context, state) {
        if (state is TagDefinitionsWithSelection) {
          print('🔍 Page: Received TagDefinitionsWithSelection state');
          print(
            '🔍 Page: Selected count: ${state.selectedTagDefinitions.length}',
          );
        } else if (state is ExportTagDefinitionsSuccess) {
          CustomSnackBar.showSuccess(context, message: state.message);
        } else if (state is ExportTagDefinitionsError) {
          CustomSnackBar.showError(context, message: state.message);
        } else if (state is DeleteSelectedTagDefinitionsSuccess) {
          CustomSnackBar.showSuccess(context, message: state.message);
        } else if (state is DeleteSelectedTagDefinitionsError) {
          CustomSnackBar.showError(context, message: state.message);
        } else if (state is DeleteTagDefinitionSuccess) {
          // Reload the data after successful deletion
          context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
          CustomSnackBar.showSuccess(
            context,
            message: 'Tag definition deleted successfully',
          );
        } else if (state is DeleteTagDefinitionError) {
          CustomSnackBar.showError(context, message: state.message);
        }
      },
      child: TagDefinitionsView(
        key: widget.tagDefinitionsViewKey,
        onShowDeleteDialog: _showDeleteDialog,
        scrollController: _scrollController,
        isFabVisible: _isFabVisible,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TagDefinition tagDefinition) {
    final bloc = context.read<TagDefinitionsBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: Text(
          'Delete Tag Definition',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${tagDefinition.name}"?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog AND trigger delete in one action
              Navigator.of(context).pop();
              bloc.add(DeleteTagDefinition(tagDefinition.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class TagDefinitionsView extends StatefulWidget {
  final Function(BuildContext, TagDefinition)? onShowDeleteDialog;
  final ScrollController? scrollController;
  final bool isFabVisible;

  const TagDefinitionsView({
    super.key,
    this.onShowDeleteDialog,
    this.scrollController,
    this.isFabVisible = true,
  });

  @override
  State<TagDefinitionsView> createState() => TagDefinitionsViewState();
}

class TagDefinitionsViewState extends State<TagDefinitionsView> {
  bool _isMultiSelectMode = false;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String searchQuery) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Only trigger search if we have data loaded
      final bloc = context.read<TagDefinitionsBloc>();
      if (bloc.state is TagDefinitionsLoaded ||
          bloc.state is TagDefinitionsSearchResults) {
        bloc.add(SearchTagDefinitions(searchQuery));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    // Only trigger search if we have data loaded
    final bloc = context.read<TagDefinitionsBloc>();
    if (bloc.state is TagDefinitionsLoaded ||
        bloc.state is TagDefinitionsSearchResults) {
      bloc.add(const SearchTagDefinitions(''));
    }
  }

  Future<void> _waitForRefreshComplete() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = context.read<TagDefinitionsBloc>().stream.listen((state) {
      if (state is TagDefinitionsLoaded || state is TagDefinitionsError) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    return completer.future;
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _clearSearch();
      }
    });
  }

  // Method to toggle search bar from outside (called by dashboard app bar)
  void toggleSearchBar() {
    _toggleSearchBar();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TagDefinitionsBloc, TagDefinitionsState>(
      listener: (context, state) {
        if (state is TagDefinitionsWithSelection) {
          setState(() {
            _isMultiSelectMode = state.isMultiSelectMode;
          });
        } else if (state is TagDefinitionsLoaded) {
          if (_isMultiSelectMode) {
            setState(() {
              _isMultiSelectMode = false;
            });
          }
        } else if (state is DeleteSelectedTagDefinitionsLoading) {
          // Show loading message during delete operation
          CustomSnackBar.showInfo(
            context,
            message: 'Deleting selected tag definitions...',
          );
        } else if (state is DeleteSelectedTagDefinitionsError) {
          // Return to normal view by disabling multi-select mode
          context.read<TagDefinitionsBloc>().add(DisableMultiSelectMode());
        }
      },
      child: BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
        builder: (context, state) {
          print('🔍 Page: BlocBuilder called with state: ${state.runtimeType}');
          if (state is TagDefinitionsWithSelection) {
            print(
              '🔍 Page: BlocBuilder - Selected count: ${state.selectedTagDefinitions.length}',
            );
          }
          return Scaffold(
            body: _buildBody(context, state),
            floatingActionButton: _buildFloatingActionButton(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TagDefinitionsState state) {
    if (state is TagDefinitionsInitial ||
        state is TagDefinitionsLoading ||
        state is DeleteSelectedTagDefinitionsLoading ||
        state is DeleteTagDefinitionLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TagDefinitionsLoaded) {
      return Column(
        children: [
          if (_showSearchBar) _buildSearchBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
                // Wait for the refresh to complete by listening to state changes
                await _waitForRefreshComplete();
              },
              child: _buildTagDefinitionsList(context, state.tagDefinitions),
            ),
          ),
        ],
      );
    } else if (state is TagDefinitionsWithSelection) {
      return Column(
        children: [
          if (_showSearchBar) _buildSearchBar(context),
          Expanded(
            child: _buildTagDefinitionsListWithSelection(context, state),
          ),
        ],
      );
    } else if (state is TagDefinitionsSearchResults) {
      return Column(
        children: [
          if (_showSearchBar) _buildSearchBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
                // Wait for the refresh to complete by listening to state changes
                await _waitForRefreshComplete();
              },
              child: _buildTagDefinitionsList(context, state.searchResults),
            ),
          ),
        ],
      );
    } else if (state is TagDefinitionsError) {
      return _buildErrorState(context, state.message);
    } else if (state is DeleteSelectedTagDefinitionsError) {
      return _buildErrorState(context, state.message);
    } else if (state is DeleteTagDefinitionError) {
      // Reload the data to show the current list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
      });
      return const Center(child: CircularProgressIndicator());
    } else if (state is DeleteTagDefinitionSuccess) {
      // After successful delete, reload the data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
      });
      return const Center(child: CircularProgressIndicator());
    }
    return const Center(child: Text('No tag definitions loaded'));
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    TagDefinitionsState state,
  ) {
    // Hide FAB during multi-select mode
    if (state is TagDefinitionsWithSelection) {
      return null;
    }

    // Hide FAB during loading states
    if (state is TagDefinitionsInitial ||
        state is TagDefinitionsLoading ||
        state is DeleteTagDefinitionLoading ||
        state is DeleteSelectedTagDefinitionsLoading) {
      return null;
    }

    return AnimatedScale(
      scale: widget.isFabVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: widget.isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FloatingActionButton(
          onPressed: () => _navigateToAddTagDefinition(context),
          tooltip: 'Add Tag Definition',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _navigateToAddTagDefinition(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const CreateTagDefinitionPage(),
          ),
        )
        .then((result) {
          // Refresh the list if a tag definition was created successfully
          if (result == true) {
            context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
          }
        });
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search tag definitions by name or description...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                )
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _toggleSearchBar,
                  tooltip: 'Close search',
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildTagDefinitionsList(
    BuildContext context,
    List<TagDefinition> tagDefinitions,
  ) {
    if (tagDefinitions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tag definitions found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tagDefinitions.length,
      itemBuilder: (context, index) {
        final tagDefinition = tagDefinitions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TagDefinitionCardWidget(
            tagDefinition: tagDefinition,
            onDelete: () =>
                widget.onShowDeleteDialog?.call(context, tagDefinition),
          ),
        );
      },
    );
  }

  Widget _buildTagDefinitionsListWithSelection(
    BuildContext context,
    TagDefinitionsWithSelection state,
  ) {
    if (state.tagDefinitions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tag definitions found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
              // Wait for the refresh to complete by listening to state changes
              await _waitForRefreshComplete();
            },
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              itemCount: state.tagDefinitions.length,
              itemBuilder: (context, index) {
                final tagDefinition = state.tagDefinitions[index];
                final isSelected = state.selectedTagDefinitions.contains(
                  tagDefinition,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableTagDefinitionCardWidget(
                    tagDefinition: tagDefinition,
                    isSelected: isSelected,
                    isMultiSelectMode: true,
                    onTap: () {
                      context.read<TagDefinitionsBloc>().add(
                        SelectTagDefinition(tagDefinition),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        TagDefinitionsMultiSelectActionBar(
          selectedTagDefinitions: state.selectedTagDefinitions,
          isAllSelected:
              state.selectedTagDefinitions.length ==
              state.tagDefinitions.length,
          allTagDefinitions: state.tagDefinitions,
          bloc: context.read<TagDefinitionsBloc>(),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
