import 'package:flutter/material.dart';

class SearchTagsForm extends StatefulWidget {
  final Function(String, int, int, String) onSearch;
  final bool isLoading;

  const SearchTagsForm({
    super.key,
    required this.onSearch,
    this.isLoading = false,
  });

  @override
  State<SearchTagsForm> createState() => _SearchTagsFormState();
}

class _SearchTagsFormState extends State<SearchTagsForm> {
  final _formKey = GlobalKey<FormState>();
  final _tagDefinitionNameController = TextEditingController();
  final _offsetController = TextEditingController();
  final _limitController = TextEditingController();
  String _selectedAudit = 'NONE';

  @override
  void initState() {
    super.initState();
    _offsetController.text = '0';
    _limitController.text = '100';
  }

  @override
  void dispose() {
    _tagDefinitionNameController.dispose();
    _offsetController.dispose();
    _limitController.dispose();
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
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search Tags',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagDefinitionNameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Definition Name',
                  hintText: 'e.g., AUTO_INVOICING_OFF',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a tag definition name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _offsetController,
                      decoration: const InputDecoration(
                        labelText: 'Offset',
                        hintText: '0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.skip_next),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter offset';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _limitController,
                      decoration: const InputDecoration(
                        labelText: 'Limit',
                        hintText: '100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter limit';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAudit,
                decoration: const InputDecoration(
                  labelText: 'Audit Level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.audiotrack),
                ),
                items: const [
                  DropdownMenuItem(value: 'NONE', child: Text('None')),
                  DropdownMenuItem(value: 'MINIMAL', child: Text('Minimal')),
                  DropdownMenuItem(value: 'SUMMARY', child: Text('Summary')),
                  DropdownMenuItem(value: 'FULL', child: Text('Full')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAudit = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading ? null : _performSearch,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(widget.isLoading ? 'Searching...' : 'Search Tags'),
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
                          'Search Parameters:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tag Definition Name: The name of the tag to search for\n'
                      '• Offset: Number of results to skip (for pagination)\n'
                      '• Limit: Maximum number of results to return\n'
                      '• Audit: Level of audit information to include',
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

  void _performSearch() {
    if (_formKey.currentState!.validate()) {
      final tagDefinitionName = _tagDefinitionNameController.text.trim();
      final offset = int.parse(_offsetController.text.trim());
      final limit = int.parse(_limitController.text.trim());
      
      widget.onSearch(tagDefinitionName, offset, limit, _selectedAudit);
    }
  }
}
