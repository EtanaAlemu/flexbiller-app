import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_state.dart';
import '../bloc/accounts_event.dart';

/// Widget that demonstrates proper usage of background updates
/// without interfering with BLoC events
class AccountsWithBackgroundUpdates extends StatefulWidget {
  const AccountsWithBackgroundUpdates({Key? key}) : super(key: key);

  @override
  State<AccountsWithBackgroundUpdates> createState() => _AccountsWithBackgroundUpdatesState();
}

class _AccountsWithBackgroundUpdatesState extends State<AccountsWithBackgroundUpdates> {
  StreamSubscription<List<Account>>? _backgroundUpdatesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBackgroundUpdatesListener();
  }

  void _initializeBackgroundUpdatesListener() {
    final bloc = context.read<AccountsBloc>();
    
    // Listen to background updates independently of BLoC events
    _backgroundUpdatesSubscription = bloc.backgroundUpdatesStream.listen(
      (freshAccounts) {
        // Show notification that fresh data is available
        _showBackgroundUpdateNotification(freshAccounts);
        
        // Optionally, you can automatically apply the updates
        // bloc.applyBackgroundUpdates(freshAccounts);
      },
      onError: (error) {
        print('Error in background updates stream: $error');
      },
    );
  }

  void _showBackgroundUpdateNotification(List<Account> freshAccounts) {
    // Show a snackbar or notification that fresh data is available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 ${freshAccounts.length} fresh accounts available'),
        action: SnackBarAction(
          label: 'Update',
          onPressed: () {
            // User chooses to apply the background updates
            final bloc = context.read<AccountsBloc>();
            bloc.applyBackgroundUpdates(freshAccounts);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundUpdatesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is AccountsLoaded) {
          return Column(
            children: [
              // Show current accounts from BLoC state
              Expanded(
                child: ListView.builder(
                  itemCount: state.accounts.length,
                  itemBuilder: (context, index) {
                    final account = state.accounts[index];
                    return ListTile(
                      title: Text(account.name),
                      subtitle: Text(account.email),
                      trailing: Text('${state.currentOffset + index + 1}/${state.totalCount}'),
                    );
                  },
                ),
              ),
              
              // Show pagination info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Page ${(state.currentOffset / 20).floor() + 1} - '
                  '${state.accounts.length} of ${state.totalCount} accounts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
        
        if (state is AllAccountsLoaded) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.accounts.length,
                  itemBuilder: (context, index) {
                    final account = state.accounts[index];
                    return ListTile(
                      title: Text(account.name),
                      subtitle: Text(account.email),
                      trailing: Text('${index + 1}/${state.totalCount}'),
                    );
                  },
                ),
              ),
            ],
          );
        }
        
        if (state is AccountsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry loading accounts
                    context.read<AccountsBloc>().add(const GetAllAccounts());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        return const Center(
          child: Text('No accounts loaded'),
        );
      },
    );
  }
}
