import 'package:flutter/material.dart';

class InvoicesLoadingWidget extends StatelessWidget {
  const InvoicesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading invoices...'),
        ],
      ),
    );
  }
}

