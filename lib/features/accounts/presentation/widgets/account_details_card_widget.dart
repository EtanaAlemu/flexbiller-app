import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import 'account_details_grid_widget.dart';

class AccountDetailsCardWidget extends StatelessWidget {
  final Account account;

  const AccountDetailsCardWidget({Key? key, required this.account})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Account Information Grid
            AccountDetailsGridWidget(account: account),
          ],
        ),
      ),
    );
  }
}
