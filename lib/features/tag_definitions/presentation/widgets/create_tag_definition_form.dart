import 'package:flutter/material.dart';

class CreateTagDefinitionForm extends StatefulWidget {
  final Function(String, String, bool, List<String>) onCreate;
  final bool isLoading;

  const CreateTagDefinitionForm({
    super.key,
    required this.onCreate,
    this.isLoading = false,
  });

  @override
  State<CreateTagDefinitionForm> createState() => _CreateTagDefinitionFormState();
}

class _CreateTagDefinitionFormState extends State<CreateTagDefinitionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isControlTag = false;
  final List<String> _selectedObjectTypes = [];

  final List<String> _availableObjectTypes = [
    'ACCOUNT',
    'SUBSCRIPTION',
    'INVOICE',
    'BUNDLE',
    'PAYMENT',
    'USER',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create Tag Definition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  hintText: 'e.g., CUSTOM_TAG',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a tag name';
                  }
                  if (value.trim().length < 2) {
                    return 'Tag name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter a description for this tag',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isControlTag,
                    onChanged: (value) {
                      setState(() {
                        _isControlTag = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control Tag',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'System-managed tag with special behavior',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Applicable Object Types',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableObjectTypes.map((type) => _buildObjectTypeChip(type)).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading ? null : _createTagDefinition,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(widget.isLoading ? 'Creating...' : 'Create Tag Definition'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Form Guidelines:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tag Name: Use descriptive names (e.g., CUSTOM_TAG, FEATURE_FLAG)\n'
                      '• Description: Explain the purpose and usage of the tag\n'
                      '• Control Tag: Enable for system-managed tags with special behavior\n'
                      '• Object Types: Select which entities can use this tag',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectTypeChip(String objectType) {
    final isSelected = _selectedObjectTypes.contains(objectType);
    
    return FilterChip(
      label: Text(objectType),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedObjectTypes.add(objectType);
          } else {
            _selectedObjectTypes.remove(objectType);
          }
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  void _createTagDefinition() {
    if (_formKey.currentState!.validate()) {
      if (_selectedObjectTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one applicable object type'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      
      widget.onCreate(name, description, _isControlTag, _selectedObjectTypes);
    }
  }
}
