import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../widgets/create_tag_definition_form.dart';

class CreateTagDefinitionPage extends StatelessWidget {
  const CreateTagDefinitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TagDefinitionsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Tag Definition'),
        ),
        body: BlocListener<TagDefinitionsBloc, TagDefinitionsState>(
          listener: (context, state) {
            if (state is CreateTagDefinitionSuccess) {
              _showSuccessDialog(context, state.tagDefinition);
            } else if (state is CreateTagDefinitionError) {
              _showErrorSnackBar(context, state.message);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CreateTagDefinitionForm(
                  onCreate: (name, description, isControlTag, applicableObjectTypes) {
                    context.read<TagDefinitionsBloc>().add(
                      CreateTagDefinition(
                        name: name,
                        description: description,
                        isControlTag: isControlTag,
                        applicableObjectTypes: applicableObjectTypes,
                      ),
                    );
                  },
                  isLoading: false,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(
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
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Best Practices:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Use descriptive names that clearly indicate the tag\'s purpose\n'
                        '• Provide detailed descriptions to help other users understand usage\n'
                        '• Only enable Control Tag for system-managed tags with special behavior\n'
                        '• Select appropriate object types based on where the tag will be used\n'
                        '• Consider naming conventions (e.g., UPPER_CASE for control tags)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, dynamic tagDefinition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tag definition "${tagDefinition.name}" has been created successfully!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildSuccessInfo('Name', tagDefinition.name),
            _buildSuccessInfo('Description', tagDefinition.description),
            _buildSuccessInfo('Type', tagDefinition.isControlTag ? 'Control Tag' : 'Custom Tag'),
            _buildSuccessInfo('Object Types', tagDefinition.applicableObjectTypes.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous page with success
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Error: $message')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
