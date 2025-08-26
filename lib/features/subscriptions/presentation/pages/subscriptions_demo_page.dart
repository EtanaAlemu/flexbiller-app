import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import 'subscriptions_page.dart';
import 'subscription_custom_fields_demo_page.dart';

class SubscriptionsDemoPage extends StatelessWidget {
  const SubscriptionsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<SubscriptionsBloc>()..add(LoadRecentSubscriptions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscriptions Demo'),
          actions: [
            IconButton(
              onPressed: () => _customFields(context),
              icon: const Icon(Icons.settings_input_component),
              tooltip: 'Custom Fields',
            ),
          ],
        ),
        body: const SubscriptionsPage(),
      ),
    );
  }

  void _customFields(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubscriptionCustomFieldsDemoPage()),
    );
  }
}
