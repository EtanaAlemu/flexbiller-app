import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/events/accounts_event.dart';

class AccountsFilterWidget extends StatefulWidget {
  const AccountsFilterWidget({Key? key}) : super(key: key);

  @override
  State<AccountsFilterWidget> createState() => _AccountsFilterWidgetState();
}

class _AccountsFilterWidgetState extends State<AccountsFilterWidget> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _selectedAuditLevel = 'FULL';

  @override
  void dispose() {
    _companyController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final company = _companyController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    // Apply company filter if provided
    if (company.isNotEmpty) {
      context.read<AccountsBloc>().add(FilterAccountsByCompany(company));
    }

    // Apply balance filter if provided
    if (balance > 0) {
      context.read<AccountsBloc>().add(
        FilterAccountsByBalance(balance, double.infinity),
      );
    }

    // Apply audit level filter
    context.read<AccountsBloc>().add(
      FilterAccountsByAuditLevel(_selectedAuditLevel),
    );

    Navigator.of(context).pop();
  }

  void _clearFilters() {
    _companyController.clear();
    _balanceController.clear();
    _selectedAuditLevel = 'FULL';

    context.read<AccountsBloc>().add(ClearFilters());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Accounts'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                hintText: 'Enter company name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Minimum Balance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter minimum balance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Audit Level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAuditLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assessment),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'FULL',
                  child: Text('Full Audit'),
                ),
                const DropdownMenuItem(
                  value: 'MINIMAL',
                  child: Text('Minimal Audit'),
                ),
                const DropdownMenuItem(value: 'NONE', child: Text('No Audit')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAuditLevel = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _clearFilters, child: const Text('Clear All')),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}
