import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_orchestrator_bloc.dart';
import '../bloc/events/accounts_event.dart';
import '../bloc/states/accounts_state.dart';
import '../widgets/edit_account_form.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/account_timeline_widget.dart';
import '../widgets/account_tags_widget.dart';
import '../bloc/account_tags_bloc.dart';
import '../widgets/account_custom_fields_widget.dart';
import '../bloc/account_custom_fields_bloc.dart';
import '../widgets/account_payment_methods_widget.dart';
import '../bloc/account_payment_methods_bloc.dart';
import '../widgets/account_payments_widget.dart';
import '../bloc/account_payments_bloc.dart';
import '../widgets/account_details_card_widget.dart';
import '../widgets/account_subscriptions_widget.dart';
import '../bloc/account_subscriptions_bloc.dart';
import '../widgets/account_invoices_widget.dart';
import '../bloc/account_invoices_bloc.dart';
import '../../../../injection_container.dart';

class AccountDetailsPage extends StatelessWidget {
  final String accountId;

  const AccountDetailsPage({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Try to get the existing BLoC from context, if not available create a new one
    try {
      final existingBloc = context.read<AccountsOrchestratorBloc>();
      return BlocProvider.value(
        value: existingBloc,
        child: AccountDetailsView(accountId: accountId),
      );
    } catch (e) {
      // If no BLoC is available in context, create a new one
      return BlocProvider(
        create: (context) => getIt<AccountsOrchestratorBloc>(),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    // Load account details after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsOrchestratorBloc>().add(
        LoadAccountDetails(widget.accountId),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsOrchestratorBloc, AccountsState>(
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
                      context.read<AccountsOrchestratorBloc>().add(
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
          return BlocListener<AccountsOrchestratorBloc, AccountsState>(
            listener: (context, state) {
              if (state is TagAssigned ||
                  state is TagRemoved ||
                  state is AccountUpdated) {
                // Refresh account details after changes
                context.read<AccountsOrchestratorBloc>().add(
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
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountTimeline(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountTags(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAllTagsForAccount(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountCustomFields(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountEmails(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountBlockingStates(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountInvoicePayments(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountAuditLogs(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
                          LoadAccountPaymentMethods(widget.accountId),
                        );
                        context.read<AccountsOrchestratorBloc>().add(
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
                      // Capture the BLoC reference before navigation
                      final accountsBloc = context
                          .read<AccountsOrchestratorBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: accountsBloc,
                            child: EditAccountForm(
                              account: account,
                              onAccountUpdated: () {
                                // Use the captured BLoC reference
                                accountsBloc.add(
                                  LoadAccountDetails(widget.accountId),
                                );
                              },
                            ),
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
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTabsSection(context, widget.accountId, account),
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

  Widget _buildTabsSection(
    BuildContext context,
    String accountId,
    Account account,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Details'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.subscriptions, size: 18),
                    SizedBox(width: 8),
                    Text('Subscriptions'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 18),
                    SizedBox(width: 8),
                    Text('Invoices'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, size: 18),
                    SizedBox(width: 8),
                    Text('Payments'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card, size: 18),
                    SizedBox(width: 8),
                    Text('Payment Methods'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label, size: 18),
                    SizedBox(width: 8),
                    Text('Tags'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category, size: 18),
                    SizedBox(width: 8),
                    Text('Custom Fields'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 18),
                    SizedBox(width: 8),
                    Text('Timeline'),
                  ],
                ),
              ),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AccountDetailsCardWidget(account: account),
              BlocProvider(
                create: (context) => getIt<AccountSubscriptionsBloc>(),
                child: AccountSubscriptionsWidget(accountId: accountId),
              ),
              BlocProvider(
                create: (context) => getIt<AccountInvoicesBloc>(),
                child: AccountInvoicesWidget(accountId: accountId),
              ),
              BlocProvider(
                create: (context) => getIt<AccountPaymentsBloc>(),
                child: AccountPaymentsWidget(accountId: accountId),
              ),
              BlocProvider(
                create: (context) => getIt<AccountPaymentMethodsBloc>(),
                child: AccountPaymentMethodsWidget(accountId: accountId),
              ),
              BlocProvider(
                create: (context) => getIt<AccountTagsBloc>(),
                child: AccountTagsWidget(accountId: accountId),
              ),
              BlocProvider(
                create: (context) => getIt<AccountCustomFieldsBloc>(),
                child: AccountCustomFieldsWidget(accountId: accountId),
              ),
              AccountTimelineWidget(accountId: accountId),
            ],
          ),
        ),
      ],
    );
  }
}
