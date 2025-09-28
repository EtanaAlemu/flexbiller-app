import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/plans_bloc.dart';
import '../widgets/plans_list_widget.dart';
import '../widgets/plans_loading_widget.dart';
import '../widgets/plans_error_widget.dart';

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
        child: BlocBuilder<PlansBloc, PlansState>(
          builder: (context, state) {
            if (state is PlansLoading) {
              return const PlansLoadingWidget();
            } else if (state is PlansRefreshing) {
              return PlansListWidget(plans: state.plans, isRefreshing: true);
            } else if (state is PlansLoaded) {
              return PlansListWidget(plans: state.plans, isRefreshing: false);
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
    );
  }
}
