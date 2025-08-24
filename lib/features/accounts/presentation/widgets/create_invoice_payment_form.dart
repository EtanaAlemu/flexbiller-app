import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class CreateInvoicePaymentForm extends StatefulWidget {
  final String accountId;

  const CreateInvoicePaymentForm({Key? key, required this.accountId}) : super(key: key);

  @override
  State<CreateInvoicePaymentForm> createState() => _CreateInvoicePaymentFormState();
}

class _CreateInvoicePaymentFormState extends State<CreateInvoicePaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _paymentMethodController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'PayPal',
    'Cash',
    'Check',
    'Wire Transfer',
  ];

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _currencyController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (state is InvoicePaymentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice payment created successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is CreateInvoicePaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create invoice payment: ${state.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Invoice Payment'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Payment Amount
                    TextFormField(
                      controller: _paymentAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount *',
                        hintText: 'Enter payment amount',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Payment amount is required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Currency
                    DropdownButtonFormField<String>(
                      value: _currencies.contains(_currencyController.text) ? _currencyController.text : null,
                      decoration: const InputDecoration(
                        labelText: 'Currency *',
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
                        if (value != null) {
                          _currencyController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Currency is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    DropdownButtonFormField<String>(
                      value: _paymentMethods.contains(_paymentMethodController.text) ? _paymentMethodController.text : null,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method *',
                        prefixIcon: Icon(Icons.payment),
                        border: OutlineInputBorder(),
                      ),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _paymentMethodController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Payment method is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Enter any additional notes',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: state is CreatingInvoicePayment
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state is CreatingInvoicePayment
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Payment',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_paymentAmountController.text);
      final currency = _currencyController.text;
      final method = _paymentMethodController.text;
      final notes = _notesController.text.isNotEmpty ? _notesController.text : null;

      context.read<AccountsBloc>().add(
            CreateInvoicePayment(
              accountId: widget.accountId,
              paymentAmount: amount,
              currency: currency,
              paymentMethod: method,
              notes: notes,
            ),
          );
    }
  }
}
