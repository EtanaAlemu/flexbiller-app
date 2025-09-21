import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../accounts/presentation/bloc/accounts_list_bloc.dart';
import '../../../accounts/presentation/bloc/events/accounts_list_events.dart';
import '../../../accounts/presentation/bloc/states/accounts_list_states.dart';
import '../../../../injection_container.dart';
import '../../../accounts/presentation/widgets/accounts_filter_widget.dart';
import '../../../accounts/presentation/widgets/account_sort_selector_widget.dart';
import '../../../accounts/presentation/widgets/export_accounts_dialog.dart';
import '../../../accounts/domain/entities/account.dart';

class AccountsActionMenu extends StatelessWidget {
  final GlobalKey? accountsViewKey;

  const AccountsActionMenu({Key? key, this.accountsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        // Filter section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'FILTER & SORT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'search',
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Search Accounts'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'filter',
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Filter Accounts'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Sort Options'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Actions section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'ACTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Export Accounts'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Refresh'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'get_all',
          child: Row(
            children: [
              Icon(
                Icons.list_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Get All Accounts'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'multi_select',
          child: Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Multi-Select Mode'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    // Get the AccountsListBloc from the current context
    final accountsBloc = context.read<AccountsListBloc>();

    switch (action) {
      case 'search':
        _toggleSearchBar();
        break;
      case 'filter':
        _showFilterDialog(context);
        break;
      case 'sort':
        _showSortDialog(context);
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'refresh':
        accountsBloc.add(const RefreshAccounts());
        break;
      case 'get_all':
        accountsBloc.add(const GetAllAccounts());
        break;
      case 'multi_select':
        // Multi-select functionality would need to be implemented in AccountsListBloc
        // For now, just show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Multi-select mode not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
    }
  }

  void _toggleSearchBar() {
    if (accountsViewKey?.currentState != null) {
      (accountsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _showFilterDialog(BuildContext context) {
    final accountsBloc = context.read<AccountsListBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: const AccountsFilterWidget(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final accountsBloc = context.read<AccountsListBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: const _SortDialog(
          currentSortBy: 'name',
          currentSortOrder: 'asc',
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    // Get current accounts from the BLoC state
    final currentState = context.read<AccountsListBloc>().state;
    List<Account> accountsToExport = [];

    // Handle all states that contain accounts
    if (currentState is AllAccountsLoaded) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsListLoaded) {
      accountsToExport = currentState.accounts;
    } else if (currentState is AccountsFiltered) {
      accountsToExport = currentState.accounts;
    } else {
      // If no accounts are loaded, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please load accounts first before exporting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ExportAccountsDialog(accounts: accountsToExport),
    ).then((result) async {
      if (result != null) {
        final format = result['format'] as String;
        await _performExport(context, accountsToExport, format);
      }
    });
  }

  Future<void> _performExport(
    BuildContext context,
    List<Account> accountsToExport,
    String format,
  ) async {
    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Preparing export of ${accountsToExport.length} accounts...',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      // First, generate the file content
      String fileContent;

      if (format.toLowerCase() == 'excel') {
        fileContent = _generateExcelContent(accountsToExport);
      } else {
        fileContent = _generateCSVContent(accountsToExport);
      }

      // Convert content to bytes
      final bytes = fileContent.codeUnits.map((e) => e.toUnsigned(8)).toList();

      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      // Show file picker to let user choose where to save
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported accounts',
        fileName: 'accounts_export_$formattedDate.${format.toLowerCase()}',
        type: format.toLowerCase() == 'excel'
            ? FileType.custom
            : FileType.custom,
        allowedExtensions: format.toLowerCase() == 'excel' ? ['xlsx'] : ['csv'],
        bytes: Uint8List.fromList(bytes),
      );

      if (outputFile == null) {
        // User cancelled file picker
        return;
      }

      // Show success message with file name and action options
      final fileName = outputFile.split('/').last;
      final filePath = outputFile;

      // Show a custom dialog with both Open and Share options
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Export Successful'),
            content: Text(
              'File exported successfully: $fileName\n\nLocation: $filePath',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await Share.shareXFiles([
                      XFile(filePath),
                    ], text: 'Exported accounts data');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File shared successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (shareError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not share file: $shareError'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Share'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openFile(context, filePath, fileName);
                },
                child: const Text('Open'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Helper method to open file with comprehensive error handling
  Future<void> _openFile(
    BuildContext context,
    String filePath,
    String fileName,
  ) async {
    try {
      // Debug: Print the file path we're trying to open
      print('Attempting to open file: $filePath');

      // Check if file exists at the specified path
      final file = File(filePath);
      final fileExists = await file.exists();
      print('File exists at path: $fileExists');

      if (!fileExists) {
        // File doesn't exist at the specified path, try to find it
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File not found at expected location.\n\nFile: $fileName\nExpected: $filePath\n\nTrying to locate file...',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        // Try to find the file in common locations
        final downloadsDir = await getDownloadsDirectory();
        final documentsDir = await getApplicationDocumentsDirectory();

        List<String> possiblePaths = [
          filePath,
          '$downloadsDir/$fileName',
          '$documentsDir/$fileName',
          '/storage/emulated/0/Download/$fileName',
          '/storage/emulated/0/Documents/$fileName',
        ];

        String? foundPath;
        for (String path in possiblePaths) {
          if (await File(path).exists()) {
            foundPath = path;
            break;
          }
        }

        if (foundPath != null) {
          print('Found file at: $foundPath');
          final result = await OpenFile.open(foundPath);
          if (result.type == ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'File opened successfully!\n\nFound at: $foundPath',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }
        }

        // Show final error with file location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not locate the exported file.\n\nFile: $fileName\nExpected: $filePath\n\nPlease check your file manager for the exported file.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
        return;
      }

      // File exists, try to open it
      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        // File opened successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File opened successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (result.type == ResultType.noAppToOpen) {
        // No app found to open the file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No app found to open $fileName.\n\nFile saved to:\n$filePath\n\nYou can find it in your file manager.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
          ),
        );
      } else if (result.message?.contains('Permission denied') == true ||
          result.message?.contains('MANAGE_EXTERNAL_STORAGE') == true) {
        // Permission denied - offer alternative sharing option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission required to open file directly.\n\nFile saved to:\n$filePath\n\nWould you like to share it instead?',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  // Try to share the file
                  await Share.shareXFiles([
                    XFile(filePath),
                  ], text: 'Exported accounts data');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File shared successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (shareError) {
                  // If sharing also fails, show manual instructions
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not share file automatically.\n\nFile saved to:\n$filePath\n\nPlease open it manually from your file manager.',
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 6),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Other error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open file: ${result.message}\n\nFile saved to:\n$filePath',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // If OpenFile fails completely, show file location
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'File saved successfully!\n\nFile: $fileName\nLocation: $filePath\n\nYou can find it in your file manager and open it manually.',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  /// Generate Excel content for accounts (simplified implementation)
  String _generateExcelContent(List<Account> accounts) {
    final buffer = StringBuffer();

    // Add headers with tab separation for better Excel compatibility
    buffer.writeln(
      'Account ID\tName\tEmail\tPhone\tBalance\tCurrency\tTime Zone',
    );

    // Add account data with tab separation
    for (final account in accounts) {
      buffer.writeln(
        '${account.id}\t'
        '${account.name ?? ''}\t'
        '${account.email ?? ''}\t'
        '${account.phone ?? ''}\t'
        '${account.accountBalance ?? 0}\t'
        '${account.currency ?? ''}\t'
        '${account.timeZone ?? ''}',
      );
    }

    return buffer.toString();
  }

  /// Generate CSV content for accounts
  String _generateCSVContent(List<Account> accounts) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln('Account ID,Name,Email,Phone,Balance,Currency,Time Zone');

    // Add account data
    for (final account in accounts) {
      buffer.writeln(
        '${account.id},'
        '${account.name ?? ''},'
        '${account.email ?? ''},'
        '${account.phone ?? ''},'
        '${account.accountBalance ?? 0},'
        '${account.currency ?? ''},'
        '${account.timeZone ?? ''}',
      );
    }

    return buffer.toString();
  }
}

class _SortDialog extends StatefulWidget {
  final String currentSortBy;
  final String currentSortOrder;

  const _SortDialog({
    required this.currentSortBy,
    required this.currentSortOrder,
  });

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort Accounts'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sort by dropdown
          DropdownButtonFormField<String>(
            value: _selectedSortBy,
            decoration: const InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'createdAt', child: Text('Created Date')),
              DropdownMenuItem(value: 'updatedAt', child: Text('Updated Date')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSortBy = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Sort order dropdown
          DropdownButtonFormField<String>(
            value: _selectedSortOrder,
            decoration: const InputDecoration(
              labelText: 'Sort order',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'asc', child: Text('Ascending')),
              DropdownMenuItem(value: 'desc', child: Text('Descending')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSortOrder = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Cancel - just close the dialog without applying changes
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // Apply the selected sort options
            context.read<AccountsListBloc>().add(
              SortAccounts(_selectedSortBy, _selectedSortOrder),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Apply Sort',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
