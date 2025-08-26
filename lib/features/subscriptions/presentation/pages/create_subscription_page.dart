import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../widgets/create_subscription_form.dart';

class CreateSubscriptionPage extends StatelessWidget {
  final String? initialAccountId;

  const CreateSubscriptionPage({super.key, this.initialAccountId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Subscription')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: CreateSubscriptionForm(
            initialAccountId: initialAccountId,
            onSuccess: () {
              // Optionally navigate back or refresh the previous page
              Navigator.of(
                context,
              ).pop(true); // Return true to indicate success
            },
          ),
        ),
      ),
    );
  }
}
