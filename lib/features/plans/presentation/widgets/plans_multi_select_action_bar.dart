import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plans_multiselect_bloc.dart';
import '../bloc/events/plans_multiselect_events.dart';
import 'export_plans_dialog.dart';

class PlansMultiSelectActionBar extends StatefulWidget {
  final List<Plan> selectedPlans;
  final bool isAllSelected;
  final List<Plan> allPlans;

  const PlansMultiSelectActionBar({
    Key? key,
    required this.selectedPlans,
    required this.isAllSelected,
    required this.allPlans,
  }) : super(key: key);

  @override
  State<PlansMultiSelectActionBar> createState() =>
      _PlansMultiSelectActionBarState();
}

class _PlansMultiSelectActionBarState extends State<PlansMultiSelectActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () {
              context.read<PlansMultiSelectBloc>().add(
                const DisableMultiSelectMode(),
              );
            },
            icon: const Icon(Icons.close),
            tooltip: 'Exit multi-select',
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(width: 8),

          // Selection count
          Text(
            '${widget.selectedPlans.length} selected',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const Spacer(),

          // Select all / Deselect all button
          IconButton(
            onPressed: () {
              if (widget.isAllSelected) {
                context.read<PlansMultiSelectBloc>().add(
                  const DeselectAllPlans(),
                );
              } else {
                context.read<PlansMultiSelectBloc>().add(
                  SelectAllPlans(plans: widget.allPlans),
                );
              }
            },
            icon: Icon(
              widget.isAllSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            tooltip: widget.isAllSelected ? 'Deselect all' : 'Select all',
            style: IconButton.styleFrom(
              foregroundColor: widget.isAllSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // Export button
          IconButton(
            onPressed: widget.selectedPlans.isNotEmpty
                ? _showExportDialog
                : null,
            icon: const Icon(Icons.download),
            tooltip: 'Export selected',
            style: IconButton.styleFrom(
              foregroundColor: widget.selectedPlans.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    // Show export dialog for better user experience
    showDialog(
      context: context,
      builder: (context) => ExportPlansDialog(plans: widget.selectedPlans),
    ).then((result) async {
      if (result != null) {
        final selectedFormat = result['format'] as String;
        await _performExport(context, widget.selectedPlans, selectedFormat);
      }
    });
  }

  Future<void> _performExport(
    BuildContext context,
    List<Plan> plansToExport,
    String format,
  ) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<PlansMultiSelectBloc>().add(BulkExportPlans(format));
  }
}
