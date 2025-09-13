import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../widgets/selectable_tag_card_widget.dart';
import '../widgets/tags_multi_select_action_bar.dart';
import '../widgets/export_tags_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger loading of tags when the page is built
    context.read<TagsBloc>().add(LoadAllTags());

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTagDialog(context),
            tooltip: 'Add Tag',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportAllTags(context),
            tooltip: 'Export All Tags',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TagsBloc>().add(RefreshTags());
            },
            tooltip: 'Refresh Tags',
          ),
        ],
      ),
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
        if (state.isMultiSelectMode)
          TagsMultiSelectActionBar(selectedTags: state.selectedTags),
        // Tags list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TagsBloc>().add(RefreshTags());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
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
    showDialog(context: context, builder: (context) => const AddTagDialog());
  }

  void _exportAllTags(BuildContext context) {
    // Get current tags from the bloc state
    final tagsBloc = context.read<TagsBloc>();
    final state = tagsBloc.state;

    List<Tag> tagsToExport = [];

    if (state is TagsLoaded) {
      tagsToExport = state.tags;
    } else if (state is TagsWithSelection) {
      tagsToExport = state.tags;
    }

    if (tagsToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showExportDialog(context, tagsToExport, 'all_tags');
  }

  void _showExportDialog(BuildContext context, List<Tag> tags, String type) {
    showDialog(
      context: context,
      builder: (context) => ExportTagsDialog(tags: tags),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final format = result['format'] as String;
        context.read<TagsBloc>().add(ExportAllTags(format: format));
      }
    });
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
