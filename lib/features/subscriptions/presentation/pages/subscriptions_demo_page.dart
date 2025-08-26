import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import 'subscriptions_page.dart';

class SubscriptionsDemoPage extends StatelessWidget {
  const SubscriptionsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<SubscriptionsBloc>()..add(LoadRecentSubscriptions()),
      child: const SubscriptionsPage(),
    );
  }
}
