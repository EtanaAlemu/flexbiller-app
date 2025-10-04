import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import '../../domain/entities/account.dart';
import "../bloc/accounts_orchestrator_bloc.dart";
import '../bloc/events/accounts_event.dart';
import '../bloc/states/accounts_state.dart';
import 'export_accounts_dialog.dart';
import 'package:flexbiller_app/main.dart';

class MultiSelectActionBar extends StatefulWidget {
  final List<Account> selectedAccounts;
  final bool isAllSelected;
  final List<Account> allAccounts;

  const MultiSelectActionBar({
    Key? key,
    required this.selectedAccounts,
    required this.isAllSelected,
    required this.allAccounts,
  }) : super(key: key);

  @override
  State<MultiSelectActionBar> createState() => _MultiSelectActionBarState();
}

class _MultiSelectActionBarState extends State<MultiSelectActionBar> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsOrchestratorBloc, AccountsState>(
      listener: (context, state) {
        print('🔍 MultiSelectActionBar: Received state: ${state.runtimeType}');
        if (state is BulkAccountsExportSuccess) {
          CustomSnackBar.showSuccess(
            context,
            message:
                'Successfully exported ${state.exportedCount} accounts to ${state.fileName}',
          );
        } else if (state is BulkAccountsExportFailure) {
          CustomSnackBar.showError(
            context,
            message: 'Export failed: ${state.message}',
          );
        } else if (state is BulkAccountsDeleting) {
          print(
            '🔍 MultiSelectActionBar: Handling BulkAccountsDeleting with ${state.accountsToDelete.length} accounts',
          );
          setState(() {
            _isDeleting = true;
          });
          CustomSnackBar.showLoading(
            context,
            message: 'Deleting ${state.accountsToDelete.length} accounts...',
          );
        } else if (state is BulkAccountsDeleted) {
          print(
            '🔍 MultiSelectActionBar: Handling BulkAccountsDeleted with ${state.deletedAccountIds.length} accounts',
          );
          setState(() {
            _isDeleting = false;
          });
          CustomSnackBar.showSuccess(
            context,
            message:
                'Successfully deleted ${state.deletedAccountIds.length} accounts',
          );
        } else if (state is BulkAccountsDeletionFailure) {
          setState(() {
            _isDeleting = false;
          });
          CustomSnackBar.showError(
            context,
            message: 'Delete failed: ${state.message}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Close button
            IconButton(
              onPressed: () => _disableMultiSelectMode(context),
              icon: const Icon(Icons.close),
              color: Colors.white,
              tooltip: 'Exit selection mode',
            ),
            const SizedBox(width: 8),
            // Selection count
            Flexible(
              child: Text(
                '${widget.selectedAccounts.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            // Select all / Deselect all button
            Flexible(
              child: TextButton.icon(
                onPressed: () => _toggleSelectAll(context),
                icon: Icon(
                  widget.isAllSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  widget.isAllSelected ? 'Deselect All' : 'Select All',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Export button
            IconButton(
              onPressed: widget.selectedAccounts.isNotEmpty
                  ? () => _showExportDialog(context)
                  : null,
              icon: const Icon(Icons.file_download),
              color: Colors.white,
              tooltip: 'Export selected',
            ),
            // Delete button
            IconButton(
              onPressed: (!_isDeleting && widget.selectedAccounts.isNotEmpty)
                  ? () => _showDeleteConfirmation(context)
                  : null,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete),
              color: _isDeleting ? Colors.white70 : Colors.white,
              tooltip: _isDeleting ? 'Deleting...' : 'Delete selected',
            ),
          ],
        ),
      ),
    );
  }

  void _disableMultiSelectMode(BuildContext context) {
    context.read<AccountsOrchestratorBloc>().add(
      const DisableMultiSelectMode(),
    );
  }

  void _toggleSelectAll(BuildContext context) {
    final bloc = context.read<AccountsOrchestratorBloc>();
    if (widget.isAllSelected) {
      bloc.add(const DeselectAllAccounts());
    } else {
      bloc.add(SelectAllAccounts(accounts: widget.allAccounts));
    }
  }

  void _showExportDialog(BuildContext context) {
    // Show export dialog for better user experience
    showDialog(
      context: context,
      builder: (context) =>
          ExportAccountsDialog(accounts: widget.selectedAccounts),
    ).then((result) async {
      if (result != null) {
        final selectedFormat = result['format'] as String;
        await _performExport(context, widget.selectedAccounts, selectedFormat);
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
                    CustomSnackBar.showSuccess(
                      context,
                      message: 'File shared successfully!',
                    );
                  } catch (shareError) {
                    CustomSnackBar.showError(
                      context,
                      message: 'Could not share file: $shareError',
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
      CustomSnackBar.showError(context, message: 'Export failed: $e');
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
        CustomSnackBar.showWarning(
          context,
          message:
              'File not found at expected location.\n\nFile: $fileName\nExpected: $filePath\n\nTrying to locate file...',
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
          await OpenFile.open(foundPath);
        } else {
          // File not found anywhere
          CustomSnackBar.showError(
            context,
            message:
                'File not found in any common location.\n\nFile: $fileName\n\nYou can find it manually in your file manager.',
          );
        }
        return;
      }

      // File exists, try to open it
      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        // Success
        CustomSnackBar.showSuccess(
          context,
          message: 'File opened successfully: $fileName',
        );
      } else if (result.type == ResultType.noAppToOpen) {
        // No app to open this file type
        CustomSnackBar.showWarning(
          context,
          message:
              'No app found to open this file type.\n\nFile saved to:\n$filePath\n\nYou can open it manually with a compatible app.',
        );
      } else if (result.type == ResultType.fileNotFound) {
        // File not found
        CustomSnackBar.showError(
          context,
          message: 'File not found: $fileName\n\nExpected location: $filePath',
        );
      } else if (result.type == ResultType.permissionDenied) {
        // Permission denied
        CustomSnackBar.showWarning(
          context,
          message:
              'Permission denied to open file.\n\nFile saved to:\n$filePath\n\nYou may need to grant file access permissions.',
        );
      } else {
        // Other error
        CustomSnackBar.showWarning(
          context,
          message:
              'Could not open file: ${result.message}\n\nFile saved to:\n$filePath',
        );
      }
    } catch (e) {
      // If OpenFile fails completely, show file location
      print('Error opening file: $e');
      CustomSnackBar.showInfo(
        context,
        message:
            'File saved successfully!\n\nFile: $fileName\nLocation: $filePath\n\nYou can find it in your file manager and open it manually.',
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

  void _showDeleteConfirmation(BuildContext context) {
    final accountsBloc = context.read<AccountsOrchestratorBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: accountsBloc,
        child: AlertDialog(
          title: const Text('Delete Selected Accounts'),
          content: Text(
            'Are you sure you want to delete ${widget.selectedAccounts.length} accounts? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccounts(accountsBloc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccounts(AccountsOrchestratorBloc accountsBloc) {
    accountsBloc.add(BulkDeleteAccounts(accounts: widget.selectedAccounts));
  }
}
