import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../widgets/tag_card_widget.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TagsBloc>()..add(LoadAllTags()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Tags'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TagsBloc>().add(RefreshTags());
              },
              tooltip: 'Refresh Tags',
            ),
          ],
        ),
        body: BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
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
          return TagCardWidget(
            tag: tag,
            onTap: () {
              // TODO: Navigate to tag details or related object
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tag: ${tag.tagDefinitionName}'),
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
            Icons.label_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tags found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no tags available at the moment',
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
}
