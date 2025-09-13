import 'package:flutter/material.dart';

class AddTagsToAccountDialog extends StatefulWidget {
  final String accountId;

  const AddTagsToAccountDialog({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AddTagsToAccountDialog> createState() => _AddTagsToAccountDialogState();
}

class _AddTagsToAccountDialogState extends State<AddTagsToAccountDialog> {
  final List<String> _availableTags = [
    'AUTO_INVOICING_OFF',
    'AUTO_INVOICING_ON',
    'HIGH_VALUE_CUSTOMER',
    'ENTERPRISE_CLIENT',
    'TRIAL_ACCOUNT',
    'PAID_ACCOUNT',
    'SUSPENDED_ACCOUNT',
    'VIP_CUSTOMER',
    'BETA_TESTER',
    'EARLY_ADOPTER',
    'PREMIUM_SUPPORT',
    'STANDARD_SUPPORT',
    'CUSTOM_INTEGRATION',
    'API_ACCESS',
    'WEBHOOK_ENABLED',
    'SMS_NOTIFICATIONS',
    'EMAIL_NOTIFICATIONS',
    'PUSH_NOTIFICATIONS',
    'AUTO_RENEWAL',
    'MANUAL_RENEWAL',
  ];

  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(context),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Tags to Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select tags to add to this account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Tags Label
          Text(
            'Select Tags:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tags Selection Area
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Selected Tags Display
                if (_selectedTags.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _removeTag(tag),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Dropdown Button
                InkWell(
                  onTap: _showTagSelectionBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedTags.isEmpty
                                ? 'Select tags'
                                : 'Tap to add more tags',
                            style: TextStyle(
                              color: _selectedTags.isEmpty
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6)
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Available Tags Count
          Text(
            '${_availableTags.length} tags available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _selectedTags.isNotEmpty ? _addTags : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              disabledBackgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.3),
            ),
            child: const Text('Add Tags'),
          ),
        ],
      ),
    );
  }

  void _showTagSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Select Tags',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose tags to add to this account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search tags...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
              const SizedBox(height: 20),

              // Tags list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _availableTags.length,
                  itemBuilder: (context, index) {
                    final tag = _availableTags[index];
                    final isSelected = _selectedTags.contains(tag);

                    return CheckboxListTile(
                      title: Text(tag),
                      subtitle: Text(
                        _getTagDescription(tag),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTags.isNotEmpty
                          ? () {
                              Navigator.of(context).pop();
                              setState(() {});
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Add ${_selectedTags.length} Tag${_selectedTags.length == 1 ? '' : 's'}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTagDescription(String tag) {
    switch (tag) {
      case 'AUTO_INVOICING_OFF':
        return 'Disable automatic invoicing for this account';
      case 'AUTO_INVOICING_ON':
        return 'Enable automatic invoicing for this account';
      case 'HIGH_VALUE_CUSTOMER':
        return 'Mark as high-value customer with special privileges';
      case 'ENTERPRISE_CLIENT':
        return 'Enterprise-level client with advanced features';
      case 'TRIAL_ACCOUNT':
        return 'Account in trial period';
      case 'PAID_ACCOUNT':
        return 'Account with active paid subscription';
      case 'SUSPENDED_ACCOUNT':
        return 'Account temporarily suspended';
      case 'VIP_CUSTOMER':
        return 'VIP customer with premium support';
      case 'BETA_TESTER':
        return 'Participant in beta testing program';
      case 'EARLY_ADOPTER':
        return 'Early adopter of new features';
      case 'PREMIUM_SUPPORT':
        return 'Premium support tier';
      case 'STANDARD_SUPPORT':
        return 'Standard support tier';
      case 'CUSTOM_INTEGRATION':
        return 'Has custom integration requirements';
      case 'API_ACCESS':
        return 'Has API access enabled';
      case 'WEBHOOK_ENABLED':
        return 'Webhook notifications enabled';
      case 'SMS_NOTIFICATIONS':
        return 'SMS notifications enabled';
      case 'EMAIL_NOTIFICATIONS':
        return 'Email notifications enabled';
      case 'PUSH_NOTIFICATIONS':
        return 'Push notifications enabled';
      case 'AUTO_RENEWAL':
        return 'Automatic renewal enabled';
      case 'MANUAL_RENEWAL':
        return 'Manual renewal required';
      default:
        return 'Custom tag for account categorization';
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _addTags() {
    if (_selectedTags.isNotEmpty) {
      // TODO: Implement actual tag addition logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedTags.length} tag${_selectedTags.length == 1 ? '' : 's'} added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
