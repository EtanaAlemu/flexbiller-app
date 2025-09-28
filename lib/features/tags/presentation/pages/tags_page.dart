import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../widgets/selectable_tag_card_widget.dart';
import '../widgets/tags_multi_select_action_bar.dart';
import '../widgets/create_tag_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  bool _isMultiSelectMode = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);

    // Trigger loading of tags when the page is built
    context.read<TagsBloc>().add(LoadAllTags());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Don't show/hide FAB during multi-select mode
    if (_isMultiSelectMode) return;

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down - hide FAB
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
        _fabAnimationController.forward();
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up - show FAB
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TagsBloc, TagsState>(
        listener: (context, state) {
          if (state is TagsExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully exported ${state.exportedCount} tags to ${state.fileName}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    _openOrShareFile(state.filePath, state.fileName, context);
                  },
                ),
              ),
            );
          } else if (state is TagsExportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is TagsDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully deleted ${state.deletedCount} tags',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is TagsDeleteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is TagsWithSelection) {
            // Handle multi-select mode changes
            if (state.isMultiSelectMode && !_isMultiSelectMode) {
              setState(() {
                _isMultiSelectMode = true;
                _isFabVisible = false;
              });
              _fabAnimationController.forward();
            } else if (!state.isMultiSelectMode && _isMultiSelectMode) {
              setState(() {
                _isMultiSelectMode = false;
                _isFabVisible = true;
              });
              _fabAnimationController.reverse();
            }
          }
        },
        child: BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
            // Handle export states
            if (state is TagsExporting) {
              return _buildExportingState(context, state);
            }

            // Handle delete states
            if (state is TagsDeleting) {
              return _buildDeletingState(context, state);
            }

            // Handle the new unified state
            if (state is TagsWithSelection) {
              return _buildTagsListWithSelection(context, state);
            }

            // Handle loading and data states
            if (state is TagsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TagsLoaded) {
              return _buildTagsList(context, state.tags);
            } else if (state is TagsError) {
              return _buildErrorState(context, state.message);
            }
            return const Center(child: Text('No tags loaded'));
          },
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: Opacity(
                    opacity: _fabAnimation.value,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        _showAddTagDialog(context);
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 4,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Tag'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTagsListWithSelection(
    BuildContext context,
    TagsWithSelection state,
  ) {
    if (state.tags.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Multi-select action bar (only show if in multi-select mode)
        if (state.isMultiSelectMode) ...[
          Builder(
            builder: (context) {
              final isAllSelected =
                  state.tags.isNotEmpty &&
                  state.selectedTags.length == state.tags.length;
              return TagsMultiSelectActionBar(
                selectedTags: state.selectedTags,
                isAllSelected: isAllSelected,
                allTags: state.tags,
              );
            },
          ),
        ],
        // Tags list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TagsBloc>().add(RefreshTags());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                final isSelected = state.selectedTags.contains(tag);
                return SelectableTagCardWidget(
                  tag: tag,
                  isSelected: isSelected,
                  isMultiSelectMode: state.isMultiSelectMode,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsList(BuildContext context, List<dynamic> tags) {
    if (tags.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TagsBloc>().add(RefreshTags());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return SelectableTagCardWidget(
            tag: tag,
            isSelected: false,
            isMultiSelectMode: false,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No tags found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no tags available at the moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagsBloc>().add(RefreshTags());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading tags',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagsBloc>().add(LoadAllTags());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateTagDialog());
  }

  Widget _buildExportingState(BuildContext context, TagsExporting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Exporting ${state.totalTags} tags to ${state.format.toUpperCase()}...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDeletingState(BuildContext context, TagsDeleting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Deleting ${state.tagsToDelete.length} tags...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _openOrShareFile(
    String filePath,
    String fileName,
    BuildContext context,
  ) async {
    try {
      // Try to open the file first
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        // If opening fails, show share dialog
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Exported tags: $fileName');
      }
    } catch (e) {
      // If both fail, show share dialog as fallback
      try {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Exported tags: $fileName');
      } catch (shareError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AddTagDialog extends StatefulWidget {
  const AddTagDialog({super.key});

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tagDefinitionNameController = TextEditingController();
  final _objectTypeController = TextEditingController();
  final _objectIdController = TextEditingController();
  final _tagDefinitionIdController = TextEditingController();

  String _selectedObjectType = 'ACCOUNT';
  bool _isLoading = false;

  final List<String> _objectTypes = [
    'ACCOUNT',
    'SUBSCRIPTION',
    'INVOICE',
    'PAYMENT',
    'USER',
  ];

  @override
  void dispose() {
    _tagDefinitionNameController.dispose();
    _objectTypeController.dispose();
    _objectIdController.dispose();
    _tagDefinitionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Tag'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tag Definition Name
              TextFormField(
                controller: _tagDefinitionNameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Definition Name *',
                  hintText: 'Enter tag definition name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tag definition name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Object Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedObjectType,
                decoration: const InputDecoration(
                  labelText: 'Object Type *',
                  border: OutlineInputBorder(),
                ),
                items: _objectTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedObjectType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Object ID
              TextFormField(
                controller: _objectIdController,
                decoration: const InputDecoration(
                  labelText: 'Object ID *',
                  hintText: 'Enter object ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Object ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tag Definition ID
              TextFormField(
                controller: _tagDefinitionIdController,
                decoration: const InputDecoration(
                  labelText: 'Tag Definition ID *',
                  hintText: 'Enter tag definition ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tag definition ID is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTag,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Tag'),
        ),
      ],
    );
  }

  void _createTag() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tag "${_tagDefinitionNameController.text}" created successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh tags list
        context.read<TagsBloc>().add(RefreshTags());
      });
    }
  }
}
