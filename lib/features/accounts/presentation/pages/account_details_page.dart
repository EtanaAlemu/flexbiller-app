import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/edit_account_form.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/account_timeline_widget.dart';
import '../widgets/account_tags_widget.dart';
import '../widgets/account_custom_fields_widget.dart';
import '../widgets/account_payment_methods_widget.dart';
import '../widgets/account_payments_widget.dart';
import '../widgets/account_details_card_widget.dart';
import '../widgets/placeholder_tab_widget.dart';
import '../widgets/account_loading_section_widget.dart';
import '../widgets/account_subscriptions_widget.dart';
import '../widgets/account_invoices_widget.dart';
import '../widgets/add_payment_method_dialog.dart';
import '../widgets/add_tags_to_account_dialog.dart';
import '../widgets/create_account_custom_field_dialog.dart';
import '../../../../injection_container.dart';

class AccountDetailsPage extends StatelessWidget {
  final String accountId;

  const AccountDetailsPage({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Try to get the existing BLoC from context, if not available create a new one
    try {
      final existingBloc = context.read<AccountsBloc>();
      return BlocProvider.value(
        value: existingBloc..add(LoadAccountDetails(accountId)),
        child: AccountDetailsView(accountId: accountId),
      );
    } catch (e) {
      // If no BLoC is available in context, create a new one
      return BlocProvider(
        create: (context) => getIt<AccountsBloc>()..add(LoadAccountDetails(accountId)),
        child: AccountDetailsView(accountId: accountId),
      );
    }
  }
}

class AccountDetailsView extends StatefulWidget {
  final String accountId;

  const AccountDetailsView({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                        LoadAccountDetails(widget.accountId),
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
                context.read<AccountsBloc>().add(
                  LoadAccountDetails(widget.accountId),
                );
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
                          LoadAccountTimeline(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountTags(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAllTagsForAccount(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountCustomFields(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountEmails(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountBlockingStates(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountInvoicePayments(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountAuditLogs(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountPaymentMethods(widget.accountId),
                        );
                        context.read<AccountsBloc>().add(
                          LoadAccountPayments(widget.accountId),
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
                                LoadAccountDetails(widget.accountId),
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
                        builder: (context) =>
                            DeleteAccountDialog(account: account),
                      );
                    },
                    tooltip: 'Delete Account',
                  ),
                ],
              ),
              floatingActionButton: _getFloatingActionButton(context),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountHeader(context, account),
                    const SizedBox(height: 24),
                    AccountLoadingSectionWidget(accountId: widget.accountId),
                    const SizedBox(height: 16),
                    _buildTabsSection(context, widget.accountId, account),
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

  Widget _buildAccountHeader(BuildContext context, Account account) {
    // Defensive null checking
    if (account.displayName.isEmpty && account.email.isEmpty) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('Invalid account data')),
        ),
      );
    }

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
                  if (account.company != null &&
                      account.company!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.company!,
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

  Widget _buildTabsSection(
    BuildContext context,
    String accountId,
    Account account,
  ) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Subscriptions'),
            Tab(text: 'Invoices'),
            Tab(text: 'Payments'),
            Tab(text: 'Payment Methods'),
            Tab(text: 'Tags'),
            Tab(text: 'Custom Fields'),
            Tab(text: 'Overdue'),
            Tab(text: 'Timeline'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              AccountDetailsCardWidget(account: account),
              AccountSubscriptionsWidget(accountId: accountId),
              AccountInvoicesWidget(accountId: accountId),
              AccountPaymentsWidget(accountId: accountId),
              AccountPaymentMethodsWidget(accountId: accountId),
              AccountTagsWidget(accountId: accountId),
              AccountCustomFieldsWidget(accountId: accountId),
              PlaceholderTabWidget(tabName: 'Overdue'),
              AccountTimelineWidget(accountId: accountId),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _getFloatingActionButton(BuildContext context) {
    switch (_currentTabIndex) {
      case 4: // Payment Methods tab
        return FloatingActionButton(
          onPressed: () => _showAddPaymentMethodDialog(context),
          tooltip: 'Add Payment Method',
          child: const Icon(Icons.add),
        );
      case 5: // Tags tab
        return FloatingActionButton(
          onPressed: () => _showAddTagsDialog(context),
          tooltip: 'Add Tags',
          child: const Icon(Icons.add),
        );
      case 6: // Custom Fields tab
        return FloatingActionButton(
          onPressed: () => _showCreateCustomFieldDialog(context),
          tooltip: 'Add Custom Field',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentMethodDialog(accountId: widget.accountId),
    );
  }

  void _showAddTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTagsToAccountDialog(accountId: widget.accountId),
    );
  }

  void _showCreateCustomFieldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          CreateAccountCustomFieldDialog(accountId: widget.accountId),
    );
  }
}
