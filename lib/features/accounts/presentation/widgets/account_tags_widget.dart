import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account_tag.dart';
import '../bloc/account_tags_bloc.dart';
import '../bloc/events/account_tags_events.dart';
import '../bloc/states/account_tags_states.dart';

class AccountTagsWidget extends StatefulWidget {
  final String accountId;

  const AccountTagsWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountTagsWidget> createState() => _AccountTagsWidgetState();
}

class _AccountTagsWidgetState extends State<AccountTagsWidget> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.d('🔍 AccountTagsWidget: initState - triggering LoadAccountTags');
    context.read<AccountTagsBloc>().add(LoadAccountTags(widget.accountId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountTagsBloc, AccountTagsState>(
      listener: (context, state) {
        _logger.d('🔍 AccountTagsWidget: Received state: ${state.runtimeType}');
        _logger.d('🔍 AccountTagsWidget: State details: $state');

        if (state is TagAssigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tag "${state.tagAssignment.tagName}" assigned successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is TagAssignmentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign tag: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is TagRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tag removed successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is TagRemovalFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove tag: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is MultipleTagsAssigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.tagAssignments.length} tags assigned successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is MultipleTagsAssignmentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign tags: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is MultipleTagsRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.tagIds.length} tags removed successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is MultipleTagsRemovalFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove tags: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AccountTagsBloc, AccountTagsState>(
        builder: (context, state) {
          _logger.d(
            '🔍 AccountTagsWidget: Building with state: ${state.runtimeType}',
          );
          _logger.d('🔍 AccountTagsWidget: State details in builder: $state');

          if (state is AccountTagsLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is AccountTagsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AccountTagsBloc>().add(
                        RefreshAccountTags(widget.accountId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AccountTagsLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tags (${state.tags.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            context.read<AccountTagsBloc>().add(
                              RefreshAccountTags(widget.accountId),
                            );
                          },
                          tooltip: 'Refresh Tags',
                        ),
                        if (state.tags.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _showRemoveAllTagsDialog(context),
                            tooltip: 'Remove All Tags',
                            color: Colors.red[400],
                          ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddTagDialog(context),
                          tooltip: 'Add Tag',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.tags.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.label_outline,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tags assigned',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add tags to categorize this account',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddTagDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Tag'),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<AccountTagsBloc>().add(
                          RefreshAccountTags(widget.accountId),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.tags.map((tag) {
                            return _buildTagChip(context, tag);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const Center(child: Text('No tags data available'));
        },
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, AccountTagAssignment tag) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: _parseColor(tag.displayColor),
        child: Icon(_parseIcon(tag.displayIcon), color: Colors.white, size: 16),
      ),
      label: Text(
        tag.tagName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      backgroundColor: _parseColor(tag.displayColor).withOpacity(0.1),
      side: BorderSide(color: _parseColor(tag.displayColor).withOpacity(0.3)),
      deleteIcon: Icon(
        Icons.remove_circle_outline,
        color: _parseColor(tag.displayColor),
        size: 20,
      ),
      onDeleted: () => _removeTag(context, tag),
      deleteButtonTooltipMessage: 'Remove tag',
    );
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    // Load all available tags first
    context.read<AccountTagsBloc>().add(
      LoadAllTagsForAccount(widget.accountId),
    );

    final selectedTagIds = await showDialog(
      context: context,
      builder: (context) => AddTagDialog(accountId: widget.accountId),
    );
    if (selectedTagIds != null && selectedTagIds is List<String>) {
      if (selectedTagIds.length == 1) {
        // Single tag assignment
        context.read<AccountTagsBloc>().add(
          AssignTagToAccount(
            accountId: widget.accountId,
            tagId: selectedTagIds.first,
          ),
        );
      } else {
        // Multiple tag assignment
        context.read<AccountTagsBloc>().add(
          AssignMultipleTagsToAccount(
            accountId: widget.accountId,
            tagIds: selectedTagIds,
          ),
        );
      }
    }
  }

  void _removeTag(BuildContext context, AccountTagAssignment tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Tag'),
        content: Text(
          'Are you sure you want to remove the tag "${tag.tagName}" from this account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountTagsBloc>().add(
                RemoveTagFromAccount(
                  accountId: widget.accountId,
                  tagId: tag.tagId,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAllTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove All Tags'),
        content: Text(
          'Are you sure you want to remove all tags from this account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Get current tags and remove them all
              final currentState = context.read<AccountTagsBloc>().state;
              if (currentState is AccountTagsLoaded) {
                final tagIds = currentState.tags
                    .map((tag) => tag.tagId)
                    .toList();
                context.read<AccountTagsBloc>().add(
                  RemoveMultipleTagsFromAccount(
                    accountId: widget.accountId,
                    tagIds: tagIds,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove All'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'label':
        return Icons.label;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'priority_high':
        return Icons.priority_high;
      case 'warning':
        return Icons.warning;
      case 'check_circle':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.label;
    }
  }
}

class AddTagDialog extends StatefulWidget {
  final String accountId;

  const AddTagDialog({Key? key, required this.accountId}) : super(key: key);

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  Set<String> selectedTagIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountTagsBloc, AccountTagsState>(
      builder: (context, state) {
        if (state is AllTagsForAccountLoading) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is AllTagsForAccountFailure) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load tags: ${state.message}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AccountTagsBloc>().add(
                    LoadAllTagsForAccount(widget.accountId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          );
        }

        if (state is AllTagsForAccountLoaded) {
          if (state.allTags.isEmpty) {
            return AlertDialog(
              title: const Text('No Tags Available'),
              content: const Text(
                'There are no tags available to assign to this account.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Add Tags'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select tags to assign to this account:'),
                  const SizedBox(height: 16),
                  ...state.allTags.map((tag) {
                    return CheckboxListTile(
                      value: selectedTagIds.contains(tag.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedTagIds.add(tag.id);
                          } else {
                            selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                      title: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _parseColor(tag.displayColor),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _parseIcon(tag.displayIcon),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(tag.name),
                        ],
                      ),
                      subtitle: tag.description != null
                          ? Text(tag.description!)
                          : null,
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedTagIds.isNotEmpty
                    ? () {
                        Navigator.of(context).pop(selectedTagIds.toList());
                      }
                    : null,
                child: Text(
                  'Add ${selectedTagIds.length} Tag${selectedTagIds.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          );
        }

        return const AlertDialog(
          content: SizedBox(
            height: 100,
            child: Center(child: Text('No tags data available')),
          ),
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'label':
        return Icons.label;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'priority_high':
        return Icons.priority_high;
      case 'warning':
        return Icons.warning;
      case 'check_circle':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.label;
    }
  }
}
