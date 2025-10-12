import 'package:flutter/material.dart';

class InvoicesErrorWidget extends StatelessWidget {
  final String message;

  const InvoicesErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Truncate long error messages to prevent UI overflow
    final displayMessage = message.length > 200
        ? '${message.substring(0, 200)}...'
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading invoices',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  displayMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Optionally, add a retry mechanism here
                // context.read<InvoicesBloc>().add(const GetInvoicesEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
