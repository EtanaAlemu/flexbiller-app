import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../widgets/update_subscription_form.dart';
import '../../domain/entities/subscription.dart';

class UpdateSubscriptionPage extends StatelessWidget {
  final Subscription subscription;

  const UpdateSubscriptionPage({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Update Subscription')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: UpdateSubscriptionForm(
            subscription: subscription,
            onSuccess: () {
              // Navigate back with success result
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ),
    );
  }
}
