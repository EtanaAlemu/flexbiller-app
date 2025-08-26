import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import 'subscriptions_page.dart';
import 'subscription_custom_fields_demo_page.dart';
import 'block_subscription_demo_page.dart';
import 'create_subscription_with_addons_demo_page.dart';
import 'subscription_audit_logs_demo_page.dart';

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
            IconButton(
              onPressed: () => _blockSubscription(context),
              icon: const Icon(Icons.block),
              tooltip: 'Block Subscription',
            ),
            IconButton(
              onPressed: () => _createSubscriptionWithAddOns(context),
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'Create with Add-ons',
            ),
            IconButton(
              onPressed: () => _auditLogs(context),
              icon: const Icon(Icons.history),
              tooltip: 'Audit Logs',
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

  void _blockSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BlockSubscriptionDemoPage()),
    );
  }

  void _createSubscriptionWithAddOns(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSubscriptionWithAddOnsDemoPage()),
    );
  }

  void _auditLogs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubscriptionAuditLogsDemoPage()),
    );
  }
}
