import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../widgets/accounts_list_widget.dart';
import '../widgets/accounts_search_widget.dart';
import '../widgets/accounts_filter_widget.dart';
import '../widgets/create_account_form.dart';
import '../../../../injection_container.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AccountsBloc>()..add(const LoadAccounts()),
      child: const AccountsView(),
    );
  }
}

class AccountsView extends StatelessWidget {
  const AccountsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
            tooltip: 'Filter Accounts',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AccountsBloc>().add(const RefreshAccounts());
            },
            tooltip: 'Refresh Accounts',
          ),
        ],
      ),
      body: Column(
        children: [
          const AccountsSearchWidget(),
          const Expanded(child: AccountsListWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateAccountForm(
                onAccountCreated: () {
                  // Refresh the accounts list after creation
                  context.read<AccountsBloc>().add(const RefreshAccounts());
                },
              ),
            ),
          );
        },
        backgroundColor: AppTheme.getSuccessColor(Theme.of(context).brightness),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AccountsFilterWidget(),
    );
  }
}
