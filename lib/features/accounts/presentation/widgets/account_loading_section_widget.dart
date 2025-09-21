import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "../bloc/accounts_orchestrator_bloc.dart";
import '../bloc/events/accounts_event.dart';
import '../bloc/states/accounts_state.dart';

class AccountLoadingSectionWidget extends StatelessWidget {
  final String accountId;

  const AccountLoadingSectionWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Account Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the button below to load additional account details like timeline, tags, custom fields, and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildLoadingButtons(context),
            const SizedBox(height: 16),
            _buildProgressIndicator(context),
            const SizedBox(height: 16),
            _buildStatusChips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingButtons(BuildContext context) {
    return BlocBuilder<AccountsOrchestratorBloc, AccountsState>(
      builder: (context, state) {
        final isLoading = _isLoading(state);
        final loadedDetails = _getLoadedDetailsCount(state);
        final hasLoadedDetails = loadedDetails > 0;

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _loadAllDetails(context),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(hasLoadedDetails ? Icons.refresh : Icons.download),
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
                    : () => _loadMissingDetails(context, state),
                icon: const Icon(Icons.download_done),
                label: const Text('Load Missing'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return BlocBuilder<AccountsOrchestratorBloc, AccountsState>(
      builder: (context, state) {
        final totalDetails = 5;
        final loadedDetails = _getLoadedDetailsCount(state);
        final progress = loadedDetails / totalDetails;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loading Progress',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '$loadedDetails/$totalDetails loaded',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  Widget _buildStatusChips(BuildContext context) {
    return BlocBuilder<AccountsOrchestratorBloc, AccountsState>(
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip('Tags', state is AccountTagsLoaded),
            _buildStatusChip(
              'Custom Fields',
              state is AccountCustomFieldsLoaded,
            ),
            _buildStatusChip(
              'Payment Methods',
              state is AccountPaymentMethodsLoaded,
            ),
            _buildStatusChip('Payments', state is AccountPaymentsLoaded),
            _buildStatusChip('Timeline', state is AccountTimelineLoaded),
          ],
        );
      },
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

  bool _isLoading(AccountsState state) {
    return state is AccountTimelineLoading ||
        state is AccountTagsLoading ||
        state is AccountCustomFieldsLoading ||
        state is AccountPaymentMethodsLoading ||
        state is AccountPaymentsLoading;
  }

  int _getLoadedDetailsCount(AccountsState state) {
    return [
      state is AccountTagsLoaded,
      state is AccountCustomFieldsLoaded,
      state is AccountPaymentMethodsLoaded,
      state is AccountPaymentsLoaded,
      state is AccountTimelineLoaded,
    ].where((loaded) => loaded).length;
  }

  void _loadAllDetails(BuildContext context) {
    context.read<AccountsOrchestratorBloc>().add(LoadAccountTags(accountId));
    context.read<AccountsOrchestratorBloc>().add(LoadAllTagsForAccount(accountId));
    context.read<AccountsOrchestratorBloc>().add(LoadAccountCustomFields(accountId));
    context.read<AccountsOrchestratorBloc>().add(LoadAccountPaymentMethods(accountId));
    context.read<AccountsOrchestratorBloc>().add(LoadAccountPayments(accountId));
    context.read<AccountsOrchestratorBloc>().add(LoadAccountTimeline(accountId));
  }

  void _loadMissingDetails(BuildContext context, AccountsState state) {
    if (state is! AccountTagsLoaded) {
      context.read<AccountsOrchestratorBloc>().add(LoadAccountTags(accountId));
    }
    if (state is! AccountCustomFieldsLoaded) {
      context.read<AccountsOrchestratorBloc>().add(LoadAccountCustomFields(accountId));
    }
    if (state is! AccountPaymentMethodsLoaded) {
      context.read<AccountsOrchestratorBloc>().add(LoadAccountPaymentMethods(accountId));
    }
    if (state is! AccountPaymentsLoaded) {
      context.read<AccountsOrchestratorBloc>().add(LoadAccountPayments(accountId));
    }
    if (state is! AccountTimelineLoaded) {
      context.read<AccountsOrchestratorBloc>().add(LoadAccountTimeline(accountId));
    }
  }
}
