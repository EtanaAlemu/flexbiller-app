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
import '../../../../injection_container.dart';

class AccountDetailsPage extends StatelessWidget {
  final String accountId;

  const AccountDetailsPage({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AccountsBloc>()
        ..add(LoadAccountDetails(accountId))
        ..add(LoadAccountTimeline(accountId))
        ..add(LoadAccountTags(accountId))
        ..add(LoadAllTagsForAccount(accountId)),
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
          return Center(
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
                ElevatedButton(
                  onPressed: () {
                    context.read<AccountsBloc>().add(
                      LoadAccountDetails(accountId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AccountDetailsLoaded) {
          final account = state.account;
          return BlocListener<AccountsBloc, AccountsState>(
            listener: (context, state) {
              if (state is TagAssigned || 
                  state is TagRemoved || 
                  state is MultipleTagsAssigned) {
                // Refresh tags after assignment/removal
                context.read<AccountsBloc>().add(LoadAccountTags(accountId));
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Account Details'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAccountForm(
                            account: account,
                            onAccountUpdated: () {
                              // Refresh account details after update
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
                        builder: (BuildContext context) => DeleteAccountDialog(
                          account: account,
                          onAccountDeleted: () {
                            Navigator.of(context).pop(); // Close details page
                            // Navigate back to accounts list
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
                    // Account Details Tabs
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(text: 'Details'),
                              Tab(text: 'Timeline'),
                              Tab(text: 'Tags'),
                            ],
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            indicatorColor: Theme.of(
                              context,
                            ).colorScheme.primary,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Center(child: Text('No account details to display'));
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
              if (account.phone.isNotEmpty)
                _buildInfoRow('Phone', account.phone),
              if (account.company.isNotEmpty)
                _buildInfoRow('Company', account.company),
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
                if (account.address1.isNotEmpty)
                  _buildInfoRow('Address Line 1', account.address1),
                if (account.address2.isNotEmpty)
                  _buildInfoRow('Address Line 2', account.address2),
                if (account.city.isNotEmpty)
                  _buildInfoRow('City', account.city),
                if (account.state.isNotEmpty)
                  _buildInfoRow('State/Province', account.state),
                if (account.country.isNotEmpty)
                  _buildInfoRow('Country', account.country),
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
              _buildBalanceRow('CBA', account.cba, account.formattedCba),
            ],
          ),
          const SizedBox(height: 16),

          // Additional Information
          if (account.notes.isNotEmpty)
            _buildSectionCard(
              context,
              title: 'Additional Information',
              icon: Icons.note,
              children: [_buildInfoRow('Notes', account.notes)],
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
}
