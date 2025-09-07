import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import 'account_info_row_widget.dart';

class AccountDetailsGridWidget extends StatelessWidget {
  final Account account;

  const AccountDetailsGridWidget({Key? key, required this.account})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Account Name and Account ID
        AccountInfoRowWidget(label: 'Account Name', value: account.name),
        AccountInfoRowWidget(label: 'Account ID', value: account.accountId),

        // Row 2: Email and Company
        AccountInfoRowWidget(label: 'Email', value: account.email),
        AccountInfoRowWidget(label: 'Company', value: account.company ?? ''),

        // Row 3: Phone and Address
        AccountInfoRowWidget(label: 'Phone', value: account.phone ?? ''),
        AccountInfoRowWidget(label: 'Address', value: account.fullAddress),

        // Row 4: Created At and Time Zone
        AccountInfoRowWidget(
          label: 'Created At',
          value: _formatDate(account.referenceTime.toString()),
        ),
        AccountInfoRowWidget(label: 'Time Zone', value: account.timeZone),

        // Row 5: Currency and Billing Cycle Day
        AccountInfoRowWidget(label: 'Currency', value: account.currency),
        AccountInfoRowWidget(
          label: 'Billing Cycle Day',
          value: account.billCycleDayLocal.toString(),
        ),

        // Row 6: Notes
        if (account.notes != null && account.notes!.isNotEmpty)
          AccountInfoRowWidget(label: 'Notes', value: account.notes!),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}
