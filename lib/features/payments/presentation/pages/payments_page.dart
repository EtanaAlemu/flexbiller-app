import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/payments_bloc.dart';
import '../widgets/payments_list_widget.dart';
import '../widgets/payments_loading_widget.dart';
import '../widgets/payments_error_widget.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentsBloc>().add(const GetPaymentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PaymentsBloc>().add(const RefreshPaymentsEvent());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, state) {
            if (state is PaymentsLoading) {
              return const PaymentsLoadingWidget();
            } else if (state is PaymentsRefreshing) {
              return PaymentsListWidget(
                payments: state.payments,
                isRefreshing: true,
              );
            } else if (state is PaymentsLoaded) {
              return PaymentsListWidget(
                payments: state.payments,
                isRefreshing: false,
              );
            } else if (state is PaymentsError) {
              return PaymentsErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<PaymentsBloc>().add(const GetPaymentsEvent());
                },
              );
            } else {
              return const PaymentsLoadingWidget();
            }
          },
        ),
      ),
    );
  }
}
