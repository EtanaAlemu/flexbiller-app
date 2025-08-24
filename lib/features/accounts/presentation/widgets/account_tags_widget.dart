import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_tag.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class AccountTagsWidget extends StatelessWidget {
  final String accountId;

  const AccountTagsWidget({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
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
                    context.read<AccountsBloc>().add(
                          RefreshAccountTags(accountId),
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
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddTagDialog(context),
                    tooltip: 'Add Tag',
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.tags.map((tag) {
                    return _buildTagChip(context, tag);
                  }).toList(),
                ),
            ],
          );
        }

        return const Center(
          child: Text('No tags data available'),
        );
      },
    );
  }

  Widget _buildTagChip(BuildContext context, AccountTagAssignment tag) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: _parseColor(tag.displayColor),
        child: Icon(
          _parseIcon(tag.displayIcon),
          color: Colors.white,
          size: 16,
        ),
      ),
      label: Text(
        tag.tagName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      backgroundColor: _parseColor(tag.displayColor).withOpacity(0.1),
      side: BorderSide(
        color: _parseColor(tag.displayColor).withOpacity(0.3),
      ),
      deleteIcon: Icon(
        Icons.remove_circle_outline,
        color: _parseColor(tag.displayColor),
        size: 20,
      ),
      onDeleted: () => _removeTag(context, tag),
      deleteButtonTooltipMessage: 'Remove tag',
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTagDialog(),
    );
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
              context.read<AccountsBloc>().add(
                    RemoveTagFromAccount(accountId, tag.tagId),
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

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
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
  const AddTagDialog({Key? key}) : super(key: key);

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  String? selectedTagId;
  List<AccountTag> availableTags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableTags();
  }

  Future<void> _loadAvailableTags() async {
    // This would load available tags from the repository
    // For now, we'll use mock data
    setState(() {
      availableTags = [
        AccountTag(
          id: '1',
          name: 'VIP',
          description: 'Very Important Person',
          color: '#FFD700',
          icon: 'star',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        ),
        AccountTag(
          id: '2',
          name: 'Premium',
          description: 'Premium customer',
          color: '#9C27B0',
          icon: 'favorite',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        ),
        AccountTag(
          id: '3',
          name: 'New',
          description: 'New customer',
          color: '#4CAF50',
          icon: 'check_circle',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a tag to assign to this account:'),
                  const SizedBox(height: 16),
                  ...availableTags.map((tag) {
                    return RadioListTile<String>(
                      value: tag.id,
                      groupValue: selectedTagId,
                      onChanged: (value) {
                        setState(() {
                          selectedTagId = value;
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
          onPressed: selectedTagId != null
              ? () {
                  Navigator.of(context).pop(selectedTagId);
                }
              : null,
          child: const Text('Add Tag'),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
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
