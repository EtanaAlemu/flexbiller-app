import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../widgets/search_tags_form.dart';
import '../widgets/tag_card_widget.dart';

class SearchTagsPage extends StatelessWidget {
  const SearchTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TagsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Tags'),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                context.read<TagsBloc>().add(ClearSearch());
              },
              tooltip: 'Clear Search',
            ),
          ],
        ),
        body: BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchTagsForm(
                    onSearch: (tagDefinitionName, offset, limit, audit) {
                      context.read<TagsBloc>().add(
                        SearchTags(
                          tagDefinitionName: tagDefinitionName,
                          offset: offset,
                          limit: limit,
                          audit: audit,
                        ),
                      );
                    },
                    isLoading: state is TagsSearchLoading,
                  ),
                  const SizedBox(height: 24),
                  _buildSearchResults(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, TagsState state) {
    if (state is TagsSearchLoading) {
      return _buildLoadingState(context);
    } else if (state is TagsSearchLoaded) {
      return _buildSearchResultsContent(context, state);
    } else if (state is TagsSearchError) {
      return _buildSearchErrorState(context, state);
    } else if (state is TagsInitial) {
      return _buildInitialState(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for Tags',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a tag definition name above to search for matching tags',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for tags...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsContent(BuildContext context, TagsSearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchSummary(context, state),
        const SizedBox(height: 16),
        if (state.tags.isEmpty)
          _buildNoResultsState(context, state)
        else
          _buildTagsList(context, state.tags),
      ],
    );
  }

  Widget _buildSearchSummary(BuildContext context, TagsSearchLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Search Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Query',
                    state.searchQuery,
                    Icons.label,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Results',
                    '${state.tags.length}',
                    Icons.list,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Offset',
                    '${state.offset}',
                    Icons.skip_next,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Limit',
                    '${state.limit}',
                    Icons.tune,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Audit Level',
              state.audit,
              Icons.audiotrack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, TagsSearchLoaded state) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
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
            'No tags found for "${state.searchQuery}" with the current search parameters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Try adjusting your search parameters:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Check the spelling of the tag definition name\n'
            '• Try a different offset or limit\n'
            '• Adjust the audit level\n'
            '• Use partial matches if supported',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(BuildContext context, List<dynamic> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found Tags (${tags.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
      ],
    );
  }

  Widget _buildSearchErrorState(BuildContext context, TagsSearchError state) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to search for "${state.searchQuery}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error.withValues(
                alpha: 0.8,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error.withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagsBloc>().add(ClearSearch());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
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
