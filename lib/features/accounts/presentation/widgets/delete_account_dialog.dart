import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class DeleteAccountDialog extends StatelessWidget {
  final Account account;

  const DeleteAccountDialog({Key? key, required this.account})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account "${account.name}" deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is AccountDeletionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this account?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Details:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${account.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (account.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${account.email}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (account.company != null &&
                      account.company!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Company: ${account.company!}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⚠️ This action cannot be undone. All account data will be permanently deleted.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is AccountDeleting
                    ? null
                    : () {
                        context.read<AccountsBloc>().add(
                          DeleteAccount(account.accountId),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: state is AccountDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Delete Account'),
              );
            },
          ),
        ],
      ),
    );
  }
}
