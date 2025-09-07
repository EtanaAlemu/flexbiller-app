import 'package:flutter/material.dart';

class AccountSortSelectorWidget extends StatefulWidget {
  final String currentSortBy;
  final String currentSortOrder;
  final Function(String sortBy, String sortOrder) onSortChanged;

  const AccountSortSelectorWidget({
    Key? key,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  State<AccountSortSelectorWidget> createState() =>
      _AccountSortSelectorWidgetState();
}

class _AccountSortSelectorWidgetState extends State<AccountSortSelectorWidget> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'Name'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'company', 'label': 'Company'},
    {'value': 'created_at', 'label': 'Created Date'},
    {'value': 'balance', 'label': 'Balance'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _selectedSortOrder == 'ASC'
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.sort),
        ],
      ),
      tooltip: 'Sort Accounts',
      onSelected: (value) {
        if (value == 'toggle_order') {
          setState(() {
            _selectedSortOrder = _selectedSortOrder == 'ASC' ? 'DESC' : 'ASC';
          });
          widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
        } else {
          setState(() {
            _selectedSortBy = value;
          });
          widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
        }
      },
      itemBuilder: (context) => [
        // Sort by options
        ..._sortOptions.map(
          (option) => PopupMenuItem<String>(
            value: option['value']!,
            child: Row(
              children: [
                Icon(
                  _selectedSortBy == option['value'] ? Icons.check : null,
                  size: 16,
                  color: _selectedSortBy == option['value']
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 8),
                Text(option['label']!),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        // Toggle order option
        PopupMenuItem<String>(
          value: 'toggle_order',
          child: Row(
            children: [
              Icon(
                _selectedSortOrder == 'ASC'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(_selectedSortOrder == 'ASC' ? 'Ascending' : 'Descending'),
            ],
          ),
        ),
      ],
    );
  }
}

