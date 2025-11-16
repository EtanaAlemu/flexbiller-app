import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account.dart';
import '../pages/account_details_page.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/edit_account_form.dart';
import "../bloc/accounts_orchestrator_bloc.dart";
import '../bloc/events/accounts_event.dart';

class SelectableAccountCardWidget extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final bool isMultiSelectMode;

  const SelectableAccountCardWidget({
    Key? key,
    required this.account,
    required this.isSelected,
    required this.isMultiSelectMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
      ),
      child: GestureDetector(
        onTap: () {
          if (isMultiSelectMode) {
            _toggleSelection(context);
          } else {
            _navigateToDetails(context);
          }
        },
        onLongPressStart: (details) {
          // Long press start - no action needed
        },
        onLongPress: () {
          // Long press handled below
          if (!isMultiSelectMode) {
            _enableMultiSelectModeAndSelect(context);
          }
        },
        child: InkWell(
          onTap: () {
            if (isMultiSelectMode) {
              _toggleSelection(context);
            } else {
              _navigateToDetails(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Selection checkbox
                  if (isMultiSelectMode)
                    Container(
                      margin: const EdgeInsets.only(right: 12.0),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(context),
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  // Account avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(account),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Account details
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
                        const SizedBox(height: 2),
                        Text(
                          account.email.isNotEmpty ? account.email : 'No email',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Balance indicator
                  if (account.hasBalance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: account.balance > 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        account.formattedBalance,
                        style: TextStyle(
                          color: account.balance > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  // Action button
                  if (!isMultiSelectMode) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Edit Account',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete Account',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(BuildContext context) {
    // Provide haptic feedback for selection
    HapticFeedback.lightImpact();

    final bloc = context.read<AccountsOrchestratorBloc>();
    if (isSelected) {
      bloc.add(DeselectAccount(account));
    } else {
      bloc.add(SelectAccount(account));
    }
  }

  void _navigateToDetails(BuildContext context) {
    // Capture the BLoC reference before navigation
    final accountsBloc = context.read<AccountsOrchestratorBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: accountsBloc,
          child: AccountDetailsPage(accountId: account.id),
        ),
      ),
    );
  }

  void _navigateToEditForm(BuildContext context) {
    // Capture the BLoC reference before navigation
    final accountsBloc = context.read<AccountsOrchestratorBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: accountsBloc,
          child: EditAccountForm(
            account: account,
            onAccountUpdated: () {
              // Refresh the accounts list after update
              accountsBloc.add(const RefreshAccounts());
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _navigateToEditForm(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    // Get the bloc from the current context before showing dialog
    final accountsBloc = context.read<AccountsOrchestratorBloc>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider.value(
        value: accountsBloc,
        child: DeleteAccountDialog(
          account: account,
        ), // No callback needed for accounts list
      ),
    );
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    // Provide haptic feedback for long press
    HapticFeedback.mediumImpact();

    final bloc = context.read<AccountsOrchestratorBloc>();
    bloc.add(EnableMultiSelectModeAndSelect(account));
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
}
