import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class CreateAccountPaymentForm extends StatefulWidget {
  final String accountId;
  final List<String> availablePaymentMethods;

  const CreateAccountPaymentForm({
    Key? key,
    required this.accountId,
    required this.availablePaymentMethods,
  }) : super(key: key);

  @override
  State<CreateAccountPaymentForm> createState() =>
      _CreateAccountPaymentFormState();
}

class _CreateAccountPaymentFormState extends State<CreateAccountPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPaymentMethodId = '';
  String _selectedTransactionType = 'PURCHASE';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();

  final List<String> _transactionTypes = [
    'PURCHASE',
    'REFUND',
    'ADJUSTMENT',
    'CHARGEBACK',
    'DISPUTE',
    'OTHER',
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CHF',
    'CNY',
    'INR',
    'BRL',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.availablePaymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = widget.availablePaymentMethods.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPaymentMethodId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<AccountsBloc>().add(
        CreateAccountPayment(
          accountId: widget.accountId,
          paymentMethodId: _selectedPaymentMethodId,
          transactionType: _selectedTransactionType,
          amount: amount,
          currency: _selectedCurrency,
          effectiveDate: _selectedDate,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          properties: _descriptionController.text.isNotEmpty
              ? {
                  'description': _descriptionController.text,
                  'isUpdatable': true,
                }
              : null,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Create Payment',
          ),
        ],
      ),
      body: BlocListener<AccountsBloc, AccountsState>(
        listener: (context, state) {
          if (state is AccountPaymentCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment created successfully: ${state.payment.currency} ${state.payment.amount}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is CreateAccountPaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create payment: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            final isLoading = state is CreatingAccountPayment;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Amount',
                                      prefixIcon: Icon(Icons.attach_money),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an amount';
                                      }
                                      final amount = double.tryParse(value);
                                      if (amount == null || amount <= 0) {
                                        return 'Please enter a valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    decoration: const InputDecoration(
                                      labelText: 'Currency',
                                      prefixIcon: Icon(Icons.currency_exchange),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _currencies.map((currency) {
                                      return DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCurrency = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedTransactionType,
                              decoration: const InputDecoration(
                                labelText: 'Transaction Type',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(),
                              ),
                              items: _transactionTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTransactionType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Effective Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selectedDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            if (widget.availablePaymentMethods.isEmpty)
                              const Card(
                                color: Colors.orange,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.white),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No payment methods available for this account. Please add a payment method first.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                value: _selectedPaymentMethodId.isNotEmpty
                                    ? _selectedPaymentMethodId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Method',
                                  prefixIcon: Icon(Icons.credit_card),
                                  border: OutlineInputBorder(),
                                  helperText:
                                      'Select the payment method to use',
                                ),
                                items: widget.availablePaymentMethods.map((
                                  methodId,
                                ) {
                                  return DropdownMenuItem(
                                    value: methodId,
                                    child: Text(
                                      'Payment Method ${methodId.substring(0, 8)}...',
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethodId = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a payment method';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                                helperText:
                                    'Provide additional details about this payment',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitForm,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.payment),
                        label: Text(
                          isLoading ? 'Creating Payment...' : 'Create Payment',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
