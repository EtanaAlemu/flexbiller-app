import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plans_bloc.dart';
import '../bloc/events/plans_multiselect_events.dart';
import '../bloc/plans_multiselect_bloc.dart';
import '../bloc/states/plans_multiselect_states.dart';
import '../pages/plan_detail_page.dart';
import 'plan_list_item.dart';

class PlansListWidget extends StatelessWidget {
  final List<Plan> plans;
  final bool isRefreshing;

  const PlansListWidget({
    super.key,
    required this.plans,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No plans available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<PlansMultiSelectBloc, PlansMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<PlansMultiSelectBloc>();
        final isMultiSelectMode = multiSelectBloc.isMultiSelectMode;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // This will be handled by the parent widget
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = multiSelectBloc.isPlanSelected(plan);

                  return PlanListItem(
                    plan: plan,
                    isMultiSelectMode: isMultiSelectMode,
                    isSelected: isSelected,
                    onTap: () {
                      if (isMultiSelectMode) {
                        multiSelectBloc.togglePlanSelection(plan);
                      } else {
                        // Navigate to plan detail
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => getIt<PlansBloc>(),
                              child: PlanDetailPage(planId: plan.id),
                            ),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!isMultiSelectMode) {
                        multiSelectBloc.add(
                          EnableMultiSelectModeAndSelect(plan),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            if (isRefreshing)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}
