import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/plan.dart';
import '../bloc/plans_bloc.dart';
import '../bloc/plans_multiselect_bloc.dart';
import '../bloc/states/plans_multiselect_states.dart';
import '../widgets/plans_list_widget.dart';
import '../widgets/plans_loading_widget.dart';
import '../widgets/plans_error_widget.dart';
import '../widgets/plans_multi_select_action_bar.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlansBloc>().add(const GetPlansEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Multi-select action bar
            BlocListener<PlansMultiSelectBloc, PlansMultiSelectState>(
              listener: (context, state) {
                if (state is BulkExportCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Plans exported successfully to: ${state.filePath}',
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is BulkExportFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: ${state.error}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: BlocBuilder<PlansMultiSelectBloc, PlansMultiSelectState>(
                builder: (context, multiSelectState) {
                  final multiSelectBloc = context.read<PlansMultiSelectBloc>();
                  final isMultiSelectMode = multiSelectBloc.isMultiSelectMode;
                  final selectedPlans = multiSelectBloc.selectedPlans;

                  if (!isMultiSelectMode) {
                    return const SizedBox.shrink();
                  }

                  return BlocBuilder<PlansBloc, PlansState>(
                    builder: (context, plansState) {
                      List<Plan> allPlans = [];
                      if (plansState is PlansLoaded) {
                        allPlans = plansState.plans;
                      } else if (plansState is PlansRefreshing) {
                        allPlans = plansState.plans;
                      }

                      final isAllSelected =
                          allPlans.isNotEmpty &&
                          selectedPlans.length == allPlans.length;

                      return PlansMultiSelectActionBar(
                        selectedPlans: selectedPlans,
                        isAllSelected: isAllSelected,
                        allPlans: allPlans,
                      );
                    },
                  );
                },
              ),
            ),

            // Main content
            Expanded(
              child: BlocBuilder<PlansBloc, PlansState>(
                builder: (context, state) {
                  if (state is PlansLoading) {
                    return const PlansLoadingWidget();
                  } else if (state is PlansRefreshing) {
                    return PlansListWidget(
                      plans: state.plans,
                      isRefreshing: true,
                    );
                  } else if (state is PlansLoaded) {
                    return PlansListWidget(
                      plans: state.plans,
                      isRefreshing: false,
                    );
                  } else if (state is PlansError) {
                    return PlansErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<PlansBloc>().add(const GetPlansEvent());
                      },
                    );
                  } else {
                    return const PlansLoadingWidget();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
