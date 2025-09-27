import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../../features/accounts/domain/entities/account.dart';
import '../../../../features/subscriptions/domain/entities/subscription.dart';

class DashboardDataGrid extends StatelessWidget {
  final List<Account> accounts;
  final List<Subscription> subscriptions;
  final bool showAccounts;

  const DashboardDataGrid({
    Key? key,
    required this.accounts,
    required this.subscriptions,
    this.showAccounts = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showAccounts ? 'Recent Accounts' : 'Recent Subscriptions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: showAccounts
                  ? SfDataGrid(
                      source: AccountDataSource(accounts),
                      columns: <GridColumn>[
                        GridColumn(
                          columnName: 'name',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Name'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'email',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Email'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'company',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Company'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'balance',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerRight,
                            child: const Text('Balance'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'currency',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Currency'),
                          ),
                        ),
                      ],
                    )
                  : SfDataGrid(
                      source: SubscriptionDataSource(subscriptions),
                      columns: <GridColumn>[
                        GridColumn(
                          columnName: 'productName',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Product'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'planName',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Plan'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'state',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Status'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'billingPeriod',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerLeft,
                            child: const Text('Billing Period'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'quantity',
                          label: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.centerRight,
                            child: const Text('Quantity'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountDataSource extends DataGridSource {
  final List<Account> accounts;

  AccountDataSource(this.accounts);

  @override
  List<DataGridRow> get rows => accounts.map<DataGridRow>((account) {
    return DataGridRow(
      cells: [
        DataGridCell(columnName: 'name', value: account.name),
        DataGridCell(columnName: 'email', value: account.email),
        DataGridCell(columnName: 'company', value: account.company ?? ''),
        DataGridCell(columnName: 'balance', value: account.formattedBalance),
        DataGridCell(columnName: 'currency', value: account.currency),
      ],
    );
  }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: dataGridCell.columnName == 'balance'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dataGridCell.value.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}

class SubscriptionDataSource extends DataGridSource {
  final List<Subscription> subscriptions;

  SubscriptionDataSource(this.subscriptions);

  @override
  List<DataGridRow> get rows => subscriptions.map<DataGridRow>((subscription) {
    return DataGridRow(
      cells: [
        DataGridCell(
          columnName: 'productName',
          value: subscription.productName,
        ),
        DataGridCell(columnName: 'planName', value: subscription.planName),
        DataGridCell(columnName: 'state', value: subscription.state),
        DataGridCell(
          columnName: 'billingPeriod',
          value: subscription.billingPeriod,
        ),
        DataGridCell(columnName: 'quantity', value: subscription.quantity),
      ],
    );
  }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: dataGridCell.columnName == 'quantity'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dataGridCell.value.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}


