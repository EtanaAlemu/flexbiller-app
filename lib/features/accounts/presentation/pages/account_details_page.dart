import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/edit_account_form.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/account_timeline_widget.dart';
import '../widgets/account_tags_widget.dart';
import '../widgets/account_custom_fields_widget.dart';
import '../widgets/account_emails_widget.dart';
import '../widgets/account_blocking_states_widget.dart';
import '../widgets/account_invoice_payments_widget.dart';
import '../widgets/account_audit_logs_widget.dart';
import '../widgets/account_payment_methods_widget.dart';
import '../widgets/account_payments_widget.dart'; // Added import
import '../../../../injection_container.dart';

class AccountDetailsPage extends StatelessWidget {
  final String accountId;

  const AccountDetailsPage({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AccountsBloc>()..add(LoadAccountDetails(accountId)),
      child: AccountDetailsView(accountId: accountId),
    );
  }
}

class AccountDetailsView extends StatelessWidget {
  final String accountId;

  const AccountDetailsView({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountDetailsFailure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account Details')),
            body: Center(
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
                    'Failed to load account details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AccountsBloc>().add(
                        LoadAccountDetails(accountId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AccountDetailsLoaded) {
          final account = state.account;
          return BlocListener<AccountsBloc, AccountsState>(
            listener: (context, state) {
              if (state is TagAssigned ||
                  state is TagRemoved ||
                  state is AccountUpdated) {
                // Refresh account details after changes
                context.read<AccountsBloc>().add(LoadAccountDetails(accountId));
              } else if (state is AccountTimelineLoaded ||
                  state is AccountTagsLoaded ||
                  state is AccountCustomFieldsLoaded ||
                  state is AccountEmailsLoaded ||
                  state is AccountBlockingStatesLoaded ||
                  state is AccountInvoicePaymentsLoaded ||
                  state is AccountAuditLogsLoaded ||
                  state is AccountPaymentMethodsLoaded ||
                  state is AccountPaymentsLoaded) {
                // Show success message for additional details loaded
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Additional account details loaded successfully',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is AccountTimelineFailure ||
                  state is AccountTagsFailure ||
                  state is AccountCustomFieldsFailure ||
                  state is AccountEmailsFailure ||
                  state is AccountBlockingStatesFailure ||
                  state is AccountInvoicePaymentsFailure ||
                  state is AccountAuditLogsFailure ||
                  state is AccountPaymentMethodsFailure ||
                  state is AccountPaymentsFailure) {
                // Show error message for failed requests
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Some account details failed to load. You can retry using the button above.',
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () {
                        // Retry loading additional details
                        context.read<AccountsBloc>().add(
                          LoadAccountTimeline(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountTags(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAllTagsForAccount(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountCustomFields(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountEmails(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountBlockingStates(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountInvoicePayments(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountAuditLogs(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountPaymentMethods(accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountPayments(accountId),
                        );
                      },
                    ),
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text('Account: ${account.name}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditAccountForm(
                            account: account,
                            onAccountUpdated: () {
                              context.read<AccountsBloc>().add(
                                LoadAccountDetails(accountId),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    tooltip: 'Edit Account',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteAccountDialog(
                          account: account,
                          onAccountDeleted: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                    tooltip: 'Delete Account',
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountHeader(context, account),
                    const SizedBox(height: 24),
                    _buildProgressiveLoadingSection(
                      context,
                      accountId,
                      account,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show loading state for initial load
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading account details...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountHeader(BuildContext context, dynamic account) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                account.displayName.isNotEmpty
                    ? account.displayName[0].toUpperCase()
                    : account.email[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (account.company.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.company,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (account.hasBalance) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: account.balance > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (account.hasCba) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Text(
                            'CBA: ${account.formattedCba}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, double amount, String formattedAmount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: amount > 0
                    ? Colors.green
                    : amount < 0
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(BuildContext context, dynamic log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getAuditLogIcon(log.changeType),
                size: 16,
                color: _getAuditLogColor(log.changeType),
              ),
              const SizedBox(width: 8),
              Text(
                log.changeType ?? 'UNKNOWN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getAuditLogColor(log.changeType),
                ),
              ),
              const Spacer(),
              if (log.changeDate != null)
                Text(
                  _formatDate(log.changeDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          if (log.changedBy != null && log.changedBy.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Changed by: ${log.changedBy}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (log.comments != null && log.comments.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(log.comments, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  IconData _getAuditLogIcon(String? changeType) {
    switch (changeType?.toUpperCase()) {
      case 'INSERT':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  Color _getAuditLogColor(String? changeType) {
    switch (changeType?.toUpperCase()) {
      case 'INSERT':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildProgressiveLoadingSection(
    BuildContext context,
    String accountId,
    Account account,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Load Additional Details Button
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Account Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click the button below to load additional account details like timeline, tags, custom fields, and more.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                    final isLoading =
                        state is AccountTimelineLoading ||
                        state is AccountTagsLoading ||
                        state is AccountCustomFieldsLoading ||
                        state is AccountEmailsLoading ||
                        state is AccountBlockingStatesLoading ||
                        state is AccountInvoicePaymentsLoading ||
                        state is AccountAuditLogsLoading ||
                        state is AccountPaymentMethodsLoading ||
                        state is AccountPaymentsLoading;

                    final loadedDetails = [
                      state is AccountTimelineLoaded,
                      state is AccountTagsLoaded,
                      state is AccountCustomFieldsLoaded,
                      state is AccountEmailsLoaded,
                      state is AccountBlockingStatesLoaded,
                      state is AccountInvoicePaymentsLoaded,
                      state is AccountAuditLogsLoaded,
                      state is AccountPaymentMethodsLoaded,
                      state is AccountPaymentsLoaded,
                    ].where((loaded) => loaded).length;

                    final hasLoadedDetails = loadedDetails > 0;

                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (hasLoadedDetails) {
                                      // Refresh all details
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTimeline(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTags(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAllTagsForAccount(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountCustomFields(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountEmails(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountBlockingStates(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountInvoicePayments(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountAuditLogs(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPaymentMethods(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPayments(accountId),
                                      );
                                    } else {
                                      // Load details for the first time
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTimeline(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTags(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAllTagsForAccount(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountCustomFields(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountEmails(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountBlockingStates(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountInvoicePayments(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountAuditLogs(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPaymentMethods(accountId),
                                      );
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPayments(accountId),
                                      );
                                    }
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    hasLoadedDetails
                                        ? Icons.refresh
                                        : Icons.download,
                                  ),
                            label: Text(
                              isLoading
                                  ? 'Loading Details...'
                                  : hasLoadedDetails
                                  ? 'Refresh All Details'
                                  : 'Load Additional Details',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasLoadedDetails
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                              foregroundColor: hasLoadedDetails
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        if (hasLoadedDetails) ...[
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Load only missing details
                                    if (state is! AccountTimelineLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTimeline(accountId),
                                      );
                                    }
                                    if (state is! AccountTagsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountTags(accountId),
                                      );
                                    }
                                    if (state is! AccountCustomFieldsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountCustomFields(accountId),
                                      );
                                    }
                                    if (state is! AccountEmailsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountEmails(accountId),
                                      );
                                    }
                                    if (state is! AccountBlockingStatesLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountBlockingStates(accountId),
                                      );
                                    }
                                    if (state
                                        is! AccountInvoicePaymentsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountInvoicePayments(accountId),
                                      );
                                    }
                                    if (state is! AccountAuditLogsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountAuditLogs(accountId),
                                      );
                                    }
                                    if (state is! AccountPaymentMethodsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPaymentMethods(accountId),
                                      );
                                    }
                                    if (state is! AccountPaymentsLoaded) {
                                      context.read<AccountsBloc>().add(
                                        LoadAccountPayments(accountId),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.download_done),
                            label: const Text('Load Missing'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Progress Indicator
                BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                    final totalDetails = 9;
                    final loadedDetails = [
                      state is AccountTimelineLoaded,
                      state is AccountTagsLoaded,
                      state is AccountCustomFieldsLoaded,
                      state is AccountEmailsLoaded,
                      state is AccountBlockingStatesLoaded,
                      state is AccountInvoicePaymentsLoaded,
                      state is AccountAuditLogsLoaded,
                      state is AccountPaymentMethodsLoaded,
                      state is AccountPaymentsLoaded,
                    ].where((loaded) => loaded).length;

                    final progress = loadedDetails / totalDetails;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Loading Progress',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '$loadedDetails/$totalDetails loaded',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Status Indicators
                BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip(
                          'Timeline',
                          state is AccountTimelineLoaded,
                        ),
                        _buildStatusChip('Tags', state is AccountTagsLoaded),
                        _buildStatusChip(
                          'Custom Fields',
                          state is AccountCustomFieldsLoaded,
                        ),
                        _buildStatusChip(
                          'Emails',
                          state is AccountEmailsLoaded,
                        ),
                        _buildStatusChip(
                          'Blocking States',
                          state is AccountBlockingStatesLoaded,
                        ),
                        _buildStatusChip(
                          'Invoice Payments',
                          state is AccountInvoicePaymentsLoaded,
                        ),
                        _buildStatusChip(
                          'Audit Logs',
                          state is AccountAuditLogsLoaded,
                        ),
                        _buildStatusChip(
                          'Payment Methods',
                          state is AccountPaymentMethodsLoaded,
                        ),
                        _buildStatusChip(
                          'Payments',
                          state is AccountPaymentsLoaded,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tabs
        DefaultTabController(
          length: 10, // Changed from 9 to 10
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Timeline'),
                  Tab(text: 'Tags'),
                  Tab(text: 'Custom Fields'),
                  Tab(text: 'Emails'),
                  Tab(text: 'Blocking States'),
                  Tab(text: 'Invoice Payments'),
                  Tab(text: 'Audit Logs'),
                  Tab(text: 'Payment Methods'),
                  Tab(text: 'Payments'), // Added
                ],
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 600, // Fixed height for tabs
                child: TabBarView(
                  children: [
                    // Details Tab
                    _buildAccountDetailsTab(context, account),
                    // Timeline Tab
                    AccountTimelineWidget(accountId: accountId),
                    // Tags Tab
                    AccountTagsWidget(accountId: accountId),
                    // Custom Fields Tab
                    AccountCustomFieldsWidget(accountId: accountId),
                    // Emails Tab
                    AccountEmailsWidget(accountId: accountId),
                    // Blocking States Tab
                    AccountBlockingStatesWidget(accountId: accountId),
                    // Invoice Payments Tab
                    AccountInvoicePaymentsWidget(accountId: accountId),
                    // Audit Logs Tab
                    AccountAuditLogsWidget(accountId: accountId),
                    // Payment Methods Tab
                    AccountPaymentMethodsWidget(accountId: accountId),
                    // Payments Tab
                    AccountPaymentsWidget(accountId: accountId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsTab(BuildContext context, Account account) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Header
          _buildAccountHeader(context, account),
          const SizedBox(height: 24),

          // Basic Information
          _buildSectionCard(
            context,
            title: 'Basic Information',
            icon: Icons.person,
            children: [
              _buildInfoRow('Name', account.name),
              _buildInfoRow('Email', account.email),
              if (account.phone != null && account.phone!.isNotEmpty)
                _buildInfoRow('Phone', account.phone!),
              if (account.company != null && account.company!.isNotEmpty)
                _buildInfoRow('Company', account.company!),
            ],
          ),
          const SizedBox(height: 16),

          // Location Information
          if (account.fullAddress.isNotEmpty)
            _buildSectionCard(
              context,
              title: 'Location Information',
              icon: Icons.location_on,
              children: [
                if (account.address1 != null && account.address1!.isNotEmpty)
                  _buildInfoRow('Address Line 1', account.address1!),
                if (account.address2 != null && account.address2!.isNotEmpty)
                  _buildInfoRow('Address Line 2', account.address2!),
                if (account.city != null && account.city!.isNotEmpty)
                  _buildInfoRow('City', account.city!),
                if (account.state != null && account.state!.isNotEmpty)
                  _buildInfoRow('State/Province', account.state!),
                if (account.country != null && account.country!.isNotEmpty)
                  _buildInfoRow('Country', account.country!),
              ],
            ),
          const SizedBox(height: 16),

          // Account Settings
          _buildSectionCard(
            context,
            title: 'Account Settings',
            icon: Icons.settings,
            children: [
              _buildInfoRow('Currency', account.currency),
              _buildInfoRow('Time Zone', account.timeZone),
              if (account.externalKey.isNotEmpty)
                _buildInfoRow('External Key', account.externalKey),
            ],
          ),
          const SizedBox(height: 16),

          // Financial Information
          _buildSectionCard(
            context,
            title: 'Financial Information',
            icon: Icons.account_balance_wallet,
            children: [
              _buildBalanceRow(
                'Balance',
                account.balance,
                account.formattedBalance,
              ),
              _buildBalanceRow(
                'CBA',
                account.accountCBA ?? 0.0,
                account.formattedCba,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Additional Information
          if (account.notes != null && account.notes!.isNotEmpty)
            _buildSectionCard(
              context,
              title: 'Additional Information',
              icon: Icons.note,
              children: [_buildInfoRow('Notes', account.notes!)],
            ),
          const SizedBox(height: 16),

          // Audit Logs
          if (account.auditLogs.isNotEmpty)
            _buildSectionCard(
              context,
              title: 'Audit Logs',
              icon: Icons.history,
              children: [
                ...account.auditLogs.map(
                  (log) => _buildAuditLogItem(context, log),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isLoaded) {
    return Chip(
      label: Text(label),
      backgroundColor: isLoaded
          ? Colors.green.withOpacity(0.2)
          : Colors.grey.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isLoaded ? Colors.green : Colors.grey,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
