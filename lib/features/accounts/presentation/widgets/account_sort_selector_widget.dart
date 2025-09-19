import 'package:flutter/material.dart';

class AccountSortSelectorWidget extends StatefulWidget {
  final String currentSortBy;
  final String currentSortOrder;
  final Function(String sortBy, String sortOrder) onSortChanged;

  const AccountSortSelectorWidget({
    super.key,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onSortChanged,
  });

  @override
  State<AccountSortSelectorWidget> createState() =>
      _AccountSortSelectorWidgetState();
}

class _AccountSortSelectorWidgetState extends State<AccountSortSelectorWidget> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'value': 'name',
      'label': 'Name',
      'icon': Icons.person_outline,
      'description': 'Sort by account name',
    },
    {
      'value': 'email',
      'label': 'Email',
      'icon': Icons.email_outlined,
      'description': 'Sort by email address',
    },
    {
      'value': 'company',
      'label': 'Company',
      'icon': Icons.business_outlined,
      'description': 'Sort by company name',
    },
    {
      'value': 'created_at',
      'label': 'Created Date',
      'icon': Icons.calendar_today_outlined,
      'description': 'Sort by creation date',
    },
    {
      'value': 'balance',
      'label': 'Balance',
      'icon': Icons.account_balance_wallet_outlined,
      'description': 'Sort by account balance',
    },
    {
      'value': 'cba',
      'label': 'CBA',
      'icon': Icons.account_balance_outlined,
      'description': 'Sort by credit balance adjustment',
    },
    {
      'value': 'currency',
      'label': 'Currency',
      'icon': Icons.attach_money_outlined,
      'description': 'Sort by currency',
    },
    {
      'value': 'phone',
      'label': 'Phone',
      'icon': Icons.phone_outlined,
      'description': 'Sort by phone number',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.sort_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort Accounts',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how to organize your accounts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort by section
          Text(
            'Sort By',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),

          // Sort options
          ..._sortOptions.map(
            (option) => _buildSortOption(option, theme, colorScheme),
          ),

          const SizedBox(height: 24),

          // Sort order section
          Text(
            'Sort Order',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),

          // Order toggle
          _buildOrderToggle(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    Map<String, dynamic> option,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedSortBy == option['value'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSortBy = option['value'] as String;
            });
            widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option['icon'] as IconData,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['label'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderToggle(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSortOrder = _selectedSortOrder == 'ASC' ? 'DESC' : 'ASC';
            });
            widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _selectedSortOrder == 'ASC'
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSortOrder == 'ASC'
                            ? 'Ascending'
                            : 'Descending',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedSortOrder == 'ASC'
                            ? 'A to Z, 1 to 9, Old to New'
                            : 'Z to A, 9 to 1, New to Old',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
