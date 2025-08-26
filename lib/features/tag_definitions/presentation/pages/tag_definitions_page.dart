import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../widgets/tag_definition_card_widget.dart';

class TagDefinitionsPage extends StatelessWidget {
  const TagDefinitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TagDefinitionsBloc>()..add(LoadTagDefinitions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tag Definitions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
              },
              tooltip: 'Refresh Tag Definitions',
            ),
          ],
        ),
        body: BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
          builder: (context, state) {
            if (state is TagDefinitionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TagDefinitionsLoaded) {
              return _buildTagDefinitionsList(context, state.tagDefinitions);
            } else if (state is TagDefinitionsError) {
              return _buildErrorState(context, state.message);
            }
            return const Center(child: Text('No tag definitions loaded'));
          },
        ),
      ),
    );
  }

  Widget _buildTagDefinitionsList(BuildContext context, List<dynamic> tagDefinitions) {
    if (tagDefinitions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tagDefinitions.length,
        itemBuilder: (context, index) {
          final tagDefinition = tagDefinitions[index];
          return TagDefinitionCardWidget(
            tagDefinition: tagDefinition,
            onTap: () {
              // TODO: Navigate to tag definition details or related objects
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tag Definition: ${tagDefinition.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
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
            Icons.category_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tag definitions found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no tag definitions available at the moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagDefinitionsBloc>().add(RefreshTagDefinitions());
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
            'Error loading tag definitions',
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
                color: Theme.of(context).colorScheme.error.withValues(
                  alpha: 0.8,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagDefinitionsBloc>().add(LoadTagDefinitions());
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
}
