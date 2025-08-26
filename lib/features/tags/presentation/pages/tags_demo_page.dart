import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import 'tags_page.dart';
import 'search_tags_page.dart';

class TagsDemoPage extends StatelessWidget {
  const TagsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<TagsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tags Demo')),
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
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tags Management',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This demo showcases the Tags feature functionality:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem('• View all available tags'),
                      _buildFeatureItem('• Search tags by definition name'),
                      _buildFeatureItem('• See tag details and metadata'),
                      _buildFeatureItem('• Filter by object types'),
                      _buildFeatureItem('• Refresh tag data'),
                      _buildFeatureItem('• Handle empty states and errors'),
                      _buildFeatureItem('• Pagination support (offset/limit)'),
                      _buildFeatureItem('• Audit level configuration'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _viewAllTags(context),
                icon: const Icon(Icons.label),
                label: const Text('View All Tags'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _searchTags(context),
                icon: const Icon(Icons.search),
                label: const Text('Search Tags'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _testTagsBloc(context),
                icon: const Icon(Icons.science),
                label: const Text('Test Tags BLoC'),
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
                  ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.api,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'API Endpoints:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildApiEndpoint(
                      'GET /api/tags',
                      'Returns all available tags',
                    ),
                    const SizedBox(height: 4),
                    _buildApiEndpoint(
                      'GET /api/tags/search/{tagDefinitionName}',
                      'Search tags with pagination and audit options',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search parameters include offset, limit, and audit level for flexible tag retrieval.',
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
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _viewAllTags(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TagsPage()));
  }

  void _searchTags(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchTagsPage()),
    );
  }

  void _testTagsBloc(BuildContext context) {
    final tagsBloc = context.read<TagsBloc>();

    // Test loading tags
    tagsBloc.add(LoadAllTags());

    // Show a snackbar to indicate the test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Testing Tags BLoC - Check the console for state changes',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
