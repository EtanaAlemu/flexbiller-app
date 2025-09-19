import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/account.dart';
import '../bloc/events/account_export_events.dart';
import '../bloc/states/account_export_states.dart';

/// BLoC for handling export operations
@injectable
class AccountExportBloc extends Bloc<ExportEvent, AccountExportState> {
  final Logger _logger = Logger();

  AccountExportBloc() : super(const AccountExportInitial()) {
    // Register event handlers
    on<ExportAccounts>(_onExportAccounts);
    on<ShareFile>(_onShareFile);
    on<BulkExportAccounts>(_onBulkExportAccounts);
  }

  Future<void> _onExportAccounts(
    ExportAccounts event,
    Emitter<AccountExportState> emit,
  ) async {
    try {
      _logger.d(
        'Starting export of ${event.accounts.length} accounts in ${event.format} format',
      );

      emit(
        AccountsExporting(
          totalAccounts: event.accounts.length,
          exportedCount: 0,
          format: event.format,
        ),
      );

      String filePath;
      String fileName;

      if (event.format.toLowerCase() == 'excel') {
        final result = await _exportToExcel(event.accounts);
        filePath = result['filePath'] as String;
        fileName = result['fileName'] as String;
      } else {
        final result = await _exportToCSV(event.accounts);
        filePath = result['filePath'] as String;
        fileName = result['fileName'] as String;
      }

      emit(
        AccountsExportSuccess(
          filePath: filePath,
          fileName: fileName,
          exportedCount: event.accounts.length,
        ),
      );

      _logger.d('Export completed successfully: $fileName');
    } catch (e) {
      _logger.e('Error exporting accounts: $e');
      emit(AccountsExportFailure('Failed to export accounts: $e'));
    }
  }

  Future<void> _onShareFile(
    ShareFile event,
    Emitter<AccountExportState> emit,
  ) async {
    try {
      _logger.d('Sharing file: ${event.fileName}');

      emit(FileSharingInProgress(filePath: event.filePath));

      await Share.shareXFiles([
        XFile(event.filePath),
      ], text: 'Exported accounts: ${event.fileName}');

      emit(FileSharingSuccess(filePath: event.filePath));
      _logger.d('File shared successfully: ${event.fileName}');
    } catch (e) {
      _logger.e('Error sharing file: $e');
      emit(FileSharingFailure('Failed to share file: $e'));
    }
  }

  Future<void> _onBulkExportAccounts(
    BulkExportAccounts event,
    Emitter<AccountExportState> emit,
  ) async {
    try {
      _logger.d('Bulk export requested in ${event.format} format');

      // Note: This would typically receive the selected accounts from the multi-select bloc
      // For now, we'll emit a failure state indicating this needs to be implemented
      emit(
        AccountsExportFailure(
          'Bulk export requires integration with multi-select bloc',
        ),
      );
    } catch (e) {
      _logger.e('Error in bulk export: $e');
      emit(AccountsExportFailure('Bulk export failed: $e'));
    }
  }

  /// Export accounts to Excel format
  Future<Map<String, String>> _exportToExcel(List<Account> accounts) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'accounts_export_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Create Excel file content
      final excelContent = _generateExcelContent(accounts);

      final file = File(filePath);
      await file.writeAsString(excelContent);

      _logger.d('Excel file created: $filePath');
      return {'filePath': filePath, 'fileName': fileName};
    } catch (e) {
      _logger.e('Error creating Excel file: $e');
      rethrow;
    }
  }

  /// Export accounts to CSV format
  Future<Map<String, String>> _exportToCSV(List<Account> accounts) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'accounts_export_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Create CSV content
      final csvContent = _generateCSVContent(accounts);

      final file = File(filePath);
      await file.writeAsString(csvContent);

      _logger.d('CSV file created: $filePath');
      return {'filePath': filePath, 'fileName': fileName};
    } catch (e) {
      _logger.e('Error creating CSV file: $e');
      rethrow;
    }
  }

  /// Generate Excel content for accounts
  String _generateExcelContent(List<Account> accounts) {
    // This is a simplified implementation
    // In a real app, you'd use a proper Excel library like 'excel' package
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(
      'Account ID,Name,Email,Company,Phone,Balance,Currency,Time Zone',
    );

    // Add account data
    for (final account in accounts) {
      buffer.writeln(
        [
          account.accountId,
          account.name,
          account.email,
          account.company ?? '',
          account.phone ?? '',
          account.accountBalance?.toString() ?? '0',
          account.currency,
          account.timeZone,
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Generate CSV content for accounts
  String _generateCSVContent(List<Account> accounts) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(
      'Account ID,Name,Email,Company,Phone,Balance,Currency,Time Zone',
    );

    // Add account data
    for (final account in accounts) {
      buffer.writeln(
        [
          _escapeCsvField(account.accountId),
          _escapeCsvField(account.name),
          _escapeCsvField(account.email),
          _escapeCsvField(account.company ?? ''),
          _escapeCsvField(account.phone ?? ''),
          _escapeCsvField(account.accountBalance?.toString() ?? '0'),
          _escapeCsvField(account.currency),
          _escapeCsvField(account.timeZone),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Escape CSV field to handle commas and quotes
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Get export statistics
  Map<String, dynamic> getExportStats() {
    final currentState = state;
    if (currentState is AccountsExportSuccess) {
      return {
        'exportedCount': currentState.exportedCount,
        'fileName': currentState.fileName,
        'filePath': currentState.filePath,
      };
    }
    return {};
  }

  /// Check if export is in progress
  bool get isExporting {
    final currentState = state;
    return currentState is AccountsExporting;
  }

  /// Check if export was successful
  bool get isExportSuccessful {
    final currentState = state;
    return currentState is AccountsExportSuccess;
  }

  /// Get last export error
  String? get lastExportError {
    final currentState = state;
    if (currentState is AccountsExportFailure) {
      return currentState.message;
    }
    return null;
  }
}
