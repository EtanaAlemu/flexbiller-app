import 'package:flutter/material.dart';

class CreateAccountCustomFieldDialog extends StatefulWidget {
  final String accountId;
  final Map<String, dynamic>? existingField; // For editing existing fields

  const CreateAccountCustomFieldDialog({
    Key? key,
    required this.accountId,
    this.existingField,
  }) : super(key: key);

  @override
  State<CreateAccountCustomFieldDialog> createState() =>
      _CreateAccountCustomFieldDialogState();
}

class _CreateAccountCustomFieldDialogState
    extends State<CreateAccountCustomFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fieldNameController = TextEditingController();
  final _fieldValueController = TextEditingController();

  String _selectedInputType = 'Text';
  bool _isEditMode = false;

  final List<String> _inputTypes = [
    'Text',
    'Number',
    'Email',
    'Phone',
    'Date',
    'Boolean',
    'URL',
    'Textarea',
    'Select',
    'Multi-Select',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingField != null;
    if (_isEditMode) {
      _fieldNameController.text = widget.existingField!['name'] ?? '';
      _fieldValueController.text = widget.existingField!['value'] ?? '';
      _selectedInputType = widget.existingField!['type'] ?? 'Text';
    }
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(context),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? 'Edit Account Custom Field'
                      : 'Create Account Custom Field',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage Account Custom Field Information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Name
            _buildInputField(
              context,
              label: 'Field Name',
              controller: _fieldNameController,
              hintText: 'Enter field name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a field name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Type
            _buildInputTypeField(context),
            const SizedBox(height: 20),

            // Field Value
            _buildInputField(
              context,
              label: 'Field Value',
              controller: _fieldValueController,
              hintText: _getFieldValueHint(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a field value';
                }
                return null;
              },
              maxLines: _selectedInputType == 'Textarea' ? 4 : 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          validator: validator,
          maxLines: maxLines,
          keyboardType: _getTextInputType(),
        ),
      ],
    );
  }

  Widget _buildInputTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedInputType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          items: _inputTypes.map((String type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedInputType = newValue ?? 'Text';
            });
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _createOrUpdateField,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(_isEditMode ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  String _getFieldValueHint() {
    switch (_selectedInputType) {
      case 'Email':
        return 'Enter email address';
      case 'Phone':
        return 'Enter phone number';
      case 'Date':
        return 'Enter date (YYYY-MM-DD)';
      case 'Number':
        return 'Enter numeric value';
      case 'URL':
        return 'Enter URL';
      case 'Textarea':
        return 'Enter detailed text';
      case 'Boolean':
        return 'Enter true or false';
      case 'Select':
        return 'Enter option value';
      case 'Multi-Select':
        return 'Enter comma-separated values';
      default:
        return 'Enter text value';
    }
  }

  TextInputType _getTextInputType() {
    switch (_selectedInputType) {
      case 'Email':
        return TextInputType.emailAddress;
      case 'Phone':
        return TextInputType.phone;
      case 'Number':
        return TextInputType.number;
      case 'URL':
        return TextInputType.url;
      case 'Textarea':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  void _createOrUpdateField() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual field creation/update logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Custom field updated successfully!'
                : 'Custom field created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
