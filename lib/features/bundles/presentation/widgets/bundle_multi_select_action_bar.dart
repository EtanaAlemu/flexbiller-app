import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/bundle.dart';
import '../bloc/bundle_multiselect_bloc.dart';
import '../bloc/events/bundle_multiselect_events.dart';
import '../bloc/states/bundle_multiselect_states.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'export_bundles_dialog.dart';

class BundleMultiSelectActionBar extends StatelessWidget {
  final List<Bundle> bundles;

  const BundleMultiSelectActionBar({Key? key, required this.bundles})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BundleMultiSelectBloc, BundleMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<BundleMultiSelectBloc>();
        final selectedCount = multiSelectBloc.selectedCount;
        final allSelected = selectedCount == bundles.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: () {
                  multiSelectBloc.add(const DisableMultiSelectMode());
                },
                icon: const Icon(Icons.close),
                tooltip: 'Close multi-select',
              ),

              const SizedBox(width: 8),

              // Selection count
              Flexible(
                child: Text(
                  '$selectedCount selected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Select All / Deselect All button
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (allSelected) {
                      multiSelectBloc.add(const DeselectAllBundles());
                    } else {
                      multiSelectBloc.add(SelectAllBundles(bundles: bundles));
                    }
                  },
                  child: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Action buttons
              if (selectedCount > 0) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                IconButton(
                  onPressed: () => _showExportDialog(context),
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    final multiSelectBloc = context.read<BundleMultiSelectBloc>();
    final selectedBundles = multiSelectBloc.selectedBundles;

    // Show export dialog for better user experience
    showDialog(
      context: context,
      builder: (context) => ExportBundlesDialog(bundles: selectedBundles),
    ).then((result) async {
      if (result != null) {
        final selectedFormat = result['format'] as String;
        await _performExport(context, selectedBundles, selectedFormat);
      }
    });
  }

  Future<void> _performExport(
    BuildContext context,
    List<Bundle> bundlesToExport,
    String format,
  ) async {
    try {
      // Show file picker to let user choose where to save
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Bundle Export',
        fileName: 'bundles_export.${format.toLowerCase()}',
        type: format.toLowerCase() == 'csv' 
            ? FileType.custom 
            : FileType.any,
        allowedExtensions: format.toLowerCase() == 'csv' 
            ? ['csv'] 
            : null,
      );

      if (outputFile == null) {
        // User cancelled the file picker
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting bundles...'),
            ],
          ),
        ),
      );

      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Exported ${bundlesToExport.length} bundles to $outputFile',
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Export failed: $e',
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final multiSelectBloc = context.read<BundleMultiSelectBloc>();
    final selectedCount = multiSelectBloc.selectedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bundles'),
        content: Text(
          'Are you sure you want to delete $selectedCount selected bundle(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _performDelete(BuildContext context) {
    // Dispatch delete event to BLoC
    context.read<BundleMultiSelectBloc>().add(const BulkDeleteBundles());

    // Listen for delete completion
    context.read<BundleMultiSelectBloc>().stream.listen((state) {
      if (state is BulkDeleteCompleted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Deleted ${state.count} bundles successfully',
        );
      } else if (state is BulkDeleteFailed) {
        CustomSnackBar.showError(
          context,
          message: 'Delete failed: ${state.error}',
        );
      }
    });
  }
}
