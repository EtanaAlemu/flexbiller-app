import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../pages/account_details_page.dart';
import '../widgets/delete_account_dialog.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';

class AccountCardWidget extends StatelessWidget {
  final Account account;

  const AccountCardWidget({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountDetailsPage(accountId: account.id),
            ),
          );
        },
        onLongPress: () {
          _enableMultiSelectModeAndSelect(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(account),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.displayName.isNotEmpty
                              ? account.displayName
                              : account.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (account.company != null &&
                            account.company!.isNotEmpty)
                          Text(
                            account.company!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _buildBalanceIndicator(context),
                ],
              ),
              const SizedBox(height: 12),
              if (account.email.isNotEmpty) ...[
                _buildInfoRow(Icons.email, account.email),
                const SizedBox(height: 4),
              ],
              if (account.phone != null && account.phone!.isNotEmpty) ...[
                _buildInfoRow(Icons.phone, account.phone!),
                const SizedBox(height: 4),
              ],
              if (account.fullAddress.isNotEmpty) ...[
                _buildInfoRow(Icons.location_on, account.fullAddress),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (account.hasBalance) ...[
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: account.balance > 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: account.balance > 0
                                ? Colors.green
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Balance: ${account.formattedBalance}',
                          style: TextStyle(
                            color: account.balance > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (account.hasCba) ...[
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'CBA: ${account.formattedCba}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Long press hint
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.touch_app,
                      size: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Get the AccountsBloc instance from the current context
                        final accountsBloc = context.read<AccountsBloc>();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) => BlocProvider.value(
                            value: accountsBloc,
                            child: DeleteAccountDialog(account: account),
                          ),
                        );
                      },
                      tooltip: 'Delete Account',
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(BuildContext context) {
    if (!account.hasBalance) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: account.balance > 0
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        account.formattedBalance,
        style: TextStyle(
          color: account.balance > 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getInitials(Account account) {
    // Try to get initials from display name first
    if (account.displayName.isNotEmpty) {
      return account.displayName[0].toUpperCase();
    }

    // Fallback to email if display name is empty
    if (account.email.isNotEmpty) {
      return account.email[0].toUpperCase();
    }

    // Fallback to name if both display name and email are empty
    if (account.name.isNotEmpty) {
      return account.name[0].toUpperCase();
    }

    // Final fallback to '?' if all fields are empty
    return '?';
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    // Provide haptic feedback for long press
    HapticFeedback.mediumImpact();

    final bloc = context.read<AccountsBloc>();
    bloc.add(const EnableMultiSelectMode());
    // Add a small delay to ensure multi-select mode is enabled before selecting
    Future.delayed(const Duration(milliseconds: 100), () {
      bloc.add(SelectAccount(account));
    });
  }
}
