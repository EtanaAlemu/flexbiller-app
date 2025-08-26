import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import 'tag_definitions_page.dart';
import 'create_tag_definition_page.dart';

class TagDefinitionsDemoPage extends StatelessWidget {
  const TagDefinitionsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<TagDefinitionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tag Definitions Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tag Definitions Management',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This demo showcases the Tag Definitions feature functionality:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem('• View all available tag definitions'),
                      _buildFeatureItem(
                        '• Distinguish between control and custom tags',
                      ),
                      _buildFeatureItem(
                        '• See applicable object types for each tag',
                      ),
                      _buildFeatureItem('• View tag descriptions and metadata'),
                      _buildFeatureItem('• Create new tag definitions'),
                      _buildFeatureItem('• Refresh tag definition data'),
                      _buildFeatureItem('• Handle empty states and errors'),
                      _buildFeatureItem('• Color-coded object type indicators'),
                      _buildFeatureItem('• Audit log information display'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _viewTagDefinitions(context),
                icon: const Icon(Icons.category),
                label: const Text('View Tag Definitions'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _createTagDefinition(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Tag Definition'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _testTagDefinitionsBloc(context),
                icon: const Icon(Icons.science),
                label: const Text('Test Tag Definitions BLoC'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.api,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'API Endpoints:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildApiEndpoint(
                      'GET /api/tagDefinitions',
                      'Returns all available tag definitions',
                    ),
                    const SizedBox(height: 4),
                    _buildApiEndpoint(
                      'POST /api/tagDefinitions',
                      'Creates a new tag definition',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create endpoint supports custom tag definitions with name, description, control tag flag, and applicable object types.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tag Definition Types:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTypeInfo(
                      'Control Tags',
                      'System-managed tags with special behavior',
                      Colors.red,
                    ),
                    _buildTypeInfo(
                      'Custom Tags',
                      'User-defined tags for categorization',
                      Colors.blue,
                    ),
                    _buildTypeInfo(
                      'Object Types',
                      'Entities that can be tagged (ACCOUNT, SUBSCRIPTION, etc.)',
                      Colors.green,
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildApiEndpoint(String endpoint, String description) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            endpoint,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeInfo(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewTagDefinitions(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TagDefinitionsPage()));
  }

  void _createTagDefinition(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateTagDefinitionPage()),
    );
  }

  void _testTagDefinitionsBloc(BuildContext context) {
    final tagDefinitionsBloc = context.read<TagDefinitionsBloc>();

    // Test loading tag definitions
    tagDefinitionsBloc.add(LoadTagDefinitions());

    // Show a snackbar to indicate the test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Testing Tag Definitions BLoC - Check the console for state changes',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
