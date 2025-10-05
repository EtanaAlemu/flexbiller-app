import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../widgets/create_tag_definition_form.dart';

class CreateTagDefinitionPage extends StatelessWidget {
  const CreateTagDefinitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<TagDefinitionsBloc>();

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Tag Definition')),
        body: BlocListener<TagDefinitionsBloc, TagDefinitionsState>(
          listener: (context, state) {
            if (state is CreateTagDefinitionSuccess) {
              _showSuccessSnackBar(context, state.tagDefinition);
              Navigator.of(
                context,
              ).pop(true); // Return to previous page with success
            } else if (state is CreateTagDefinitionError) {
              _showErrorSnackBar(context, state.message);
            }
          },
          child: BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
            builder: (context, state) {
              final isLoading = state is CreateTagDefinitionLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CreateTagDefinitionForm(
                      onCreate:
                          (
                            name,
                            description,
                            isControlTag,
                            applicableObjectTypes,
                          ) {
                            bloc.add(
                              CreateTagDefinition(
                                name: name,
                                description: description,
                                isControlTag: isControlTag,
                                applicableObjectTypes: applicableObjectTypes,
                              ),
                            );
                          },
                      isLoading: isLoading,
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
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Best Practices:',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, dynamic tagDefinition) {
    CustomSnackBar.showSuccess(
      context,
      message: 'Tag definition "${tagDefinition.name}" created successfully!',
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    CustomSnackBar.showError(context, message: message);
  }
}
