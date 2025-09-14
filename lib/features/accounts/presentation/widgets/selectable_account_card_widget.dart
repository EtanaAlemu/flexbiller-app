import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../pages/account_details_page.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';

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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isMultiSelectMode) {
            _toggleSelection(context);
          } else {
            _navigateToDetails(context);
          }
        },
        onLongPress: () {
          if (!isMultiSelectMode) {
            _enableMultiSelectModeAndSelect(context);
          }
        },
        borderRadius: BorderRadius.circular(12),
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
              // Account details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name ?? 'Unnamed Account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.email ?? 'No email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'ID: ${account.id.length > 8 ? account.id.substring(0, 8) : account.id}...',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (account.balance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getBalanceColor(
                                context,
                                account.balance!,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _getBalanceColor(
                                    context,
                                    account.balance!,
                                  ).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '\$${account.balance!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action button or long press hint
              if (!isMultiSelectMode)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _navigateToDetails(context),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
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

  void _toggleSelection(BuildContext context) {
    // Provide haptic feedback for selection
    HapticFeedback.lightImpact();

    final bloc = context.read<AccountsBloc>();
    if (isSelected) {
      bloc.add(DeselectAccount(account));
    } else {
      bloc.add(SelectAccount(account));
    }
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailsPage(accountId: account.id),
      ),
    );
  }

  void _enableMultiSelectMode(BuildContext context) {
    final bloc = context.read<AccountsBloc>();
    bloc.add(const EnableMultiSelectMode());
    bloc.add(SelectAccount(account));
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

  String _getInitials(Account account) {
    final name = account.name ?? 'U';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Color _getBalanceColor(BuildContext context, double balance) {
    if (balance > 0) {
      return Colors.green;
    } else if (balance < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}
