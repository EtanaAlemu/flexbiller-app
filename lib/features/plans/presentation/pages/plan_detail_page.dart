import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/plans_bloc.dart';
import '../widgets/plan_detail_widget.dart';
import '../widgets/plan_loading_widget.dart';
import '../widgets/plan_error_widget.dart';

class PlanDetailPage extends StatefulWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlansBloc>().add(GetPlanByIdEvent(widget.planId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PlansBloc>().add(GetPlanByIdEvent(widget.planId));
            },
            tooltip: 'Refresh Plan',
          ),
        ],
      ),
      body: BlocBuilder<PlansBloc, PlansState>(
        builder: (context, state) {
          if (state is PlanLoading) {
            return const PlanLoadingWidget();
          } else if (state is PlanLoaded) {
            return PlanDetailWidget(plan: state.plan);
          } else if (state is PlanError) {
            return PlanErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<PlansBloc>().add(GetPlanByIdEvent(widget.planId));
              },
            );
          } else {
            return const PlanLoadingWidget();
          }
        },
      ),
    );
  }
}
