import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class EditAccountForm extends StatefulWidget {
  final Account account;
  final VoidCallback? onAccountUpdated;

  const EditAccountForm({Key? key, required this.account, this.onAccountUpdated}) : super(key: key);

  @override
  State<EditAccountForm> createState() => _EditAccountFormState();
}

class _EditAccountFormState extends State<EditAccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _notesController;
  
  late String _selectedCurrency;
  late String _selectedTimeZone;
  late String _selectedCountry;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'ETB', 'KES', 'NGN'];
  final List<String> _timeZones = ['GMT', 'UTC', 'EST', 'PST', 'CET', 'EAT'];
  final List<String> _countries = ['US', 'ET', 'KE', 'NG', 'GB', 'DE', 'FR'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.account.name);
    _emailController = TextEditingController(text: widget.account.email);
    _phoneController = TextEditingController(text: widget.account.phone);
    _companyController = TextEditingController(text: widget.account.company);
    _address1Controller = TextEditingController(text: widget.account.address1);
    _address2Controller = TextEditingController(text: widget.account.address2);
    _cityController = TextEditingController(text: widget.account.city);
    _stateController = TextEditingController(text: widget.account.state);
    _notesController = TextEditingController(text: widget.account.notes);
    
    _selectedCurrency = widget.account.currency;
    _selectedTimeZone = widget.account.timeZone;
    _selectedCountry = widget.account.country;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedAccount = widget.account.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        currency: _selectedCurrency,
        timeZone: _selectedTimeZone,
        address1: _address1Controller.text.trim(),
        address2: _address2Controller.text.trim(),
        company: _companyController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _selectedCountry,
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
      );

      context.read<AccountsBloc>().add(UpdateAccount(updatedAccount));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (state is AccountUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account "${state.account.name}" updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onAccountUpdated?.call();
          Navigator.of(context).pop();
        } else if (state is AccountUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update account: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Account'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Basic Information
                  _buildSectionHeader('Basic Information'),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Account Name *',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Account name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _companyController,
                    label: 'Company',
                  ),
                  const SizedBox(height: 24),

                  // Location Information
                  _buildSectionHeader('Location Information'),
                  _buildTextField(
                    controller: _address1Controller,
                    label: 'Address Line 1',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _address2Controller,
                    label: 'Address Line 2',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _cityController, label: 'City'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stateController,
                    label: 'State/Province',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Country',
                    value: _selectedCountry,
                    items: _countries,
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Account Settings
                  _buildSectionHeader('Account Settings'),
                  _buildDropdown(
                    label: 'Currency',
                    value: _selectedCurrency,
                    items: _currencies,
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Time Zone',
                    value: _selectedTimeZone,
                    items: _timeZones,
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeZone = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Additional Information
                  _buildSectionHeader('Additional Information'),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AccountUpdating ? null : _submitForm,
                      child: state is AccountUpdating
                          ? const CircularProgressIndicator()
                          : const Text('Update Account'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
