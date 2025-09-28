import 'package:flutter/material.dart';

import '../../domain/entities/plan.dart';
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

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            // This will be handled by the parent widget
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return PlanListItem(plan: plan);
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
  }
}
