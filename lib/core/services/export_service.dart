import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:excel/excel.dart';
import '../../features/accounts/domain/entities/account.dart';

abstract class ExportService {
  Future<String> exportAccountsToCSV(List<Account> accounts);
  Future<String> exportAccountsToExcel(List<Account> accounts);
}

@injectable
@LazySingleton(as: ExportService)
class ExportServiceImpl implements ExportService {
  @override
  Future<String> exportAccountsToCSV(List<Account> accounts) async {
    try {
      // Use application documents directory which doesn't require storage permissions
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'accounts_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Create CSV content
      final csvContent = _generateCSVContent(accounts);

      // Write to file
      await file.writeAsString(csvContent);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  @override
  Future<String> exportAccountsToExcel(List<Account> accounts) async {
    try {
      // Use application documents directory which doesn't require storage permissions
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'accounts_export_$timestamp.xlsx';
      final file = File('${directory.path}/$fileName');

      // Create actual Excel file
      final excelBytes = _generateExcelContent(accounts);
      await file.writeAsBytes(excelBytes);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export Excel: $e');
    }
  }

  Uint8List _generateExcelContent(List<Account> accounts) {
    // Create a new Excel file
    final excel = Excel.createExcel();

    // Delete the default sheet
    excel.delete('Sheet1');

    // Create a new sheet for accounts
    final sheet = excel['Accounts'];

    // Define headers
    final headers = [
      'Account ID',
      'Name',
      'Email',
      'Company',
      'Phone',
      'Address',
      'City',
      'State',
      'Country',
      'Currency',
      'Time Zone',
      'Balance',
      'CBA',
      'Created At',
      'Notes',
    ];

    // Add headers to the first row
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue50,
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    // Add account data
    for (int rowIndex = 0; rowIndex < accounts.length; rowIndex++) {
      final account = accounts[rowIndex];
      final row = rowIndex + 1; // +1 because headers are in row 0

      // Account ID
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        account.accountId,
      );

      // Name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        account.name,
      );

      // Email
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(
        account.email,
      );

      // Company
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(
        account.company ?? '',
      );

      // Phone
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(
        account.phone ?? '',
      );

      // Address
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue(
        account.fullAddress,
      );

      // City
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue(
        account.city ?? '',
      );

      // State
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = TextCellValue(
        account.state ?? '',
      );

      // Country
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          .value = TextCellValue(
        account.country ?? '',
      );

      // Currency
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          .value = TextCellValue(
        account.currency,
      );

      // Time Zone
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
          .value = TextCellValue(
        account.timeZone,
      );

      // Balance
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row))
          .value = DoubleCellValue(
        account.accountBalance ?? 0.0,
      );

      // CBA
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row))
          .value = DoubleCellValue(
        account.accountCBA ?? 0.0,
      );

      // Created At
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row))
          .value = TextCellValue(
        account.referenceTime.toIso8601String(),
      );

      // Notes
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: row))
          .value = TextCellValue(
        account.notes ?? '',
      );
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }

    // Add some styling to the data rows
    for (int rowIndex = 1; rowIndex <= accounts.length; rowIndex++) {
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
        );
        cell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Left,
          verticalAlign: VerticalAlign.Center,
        );
      }
    }

    // Save the Excel file
    return Uint8List.fromList(excel.save()!);
  }

  String _generateCSVContent(List<Account> accounts) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Account ID,Name,Email,Company,Phone,Address,City,State,Country,Currency,Time Zone,Balance,CBA,Created At,Notes',
    );

    // CSV Data
    for (final account in accounts) {
      buffer.writeln(
        [
          _escapeCsvField(account.accountId),
          _escapeCsvField(account.name),
          _escapeCsvField(account.email),
          _escapeCsvField(account.company ?? ''),
          _escapeCsvField(account.phone ?? ''),
          _escapeCsvField(account.fullAddress),
          _escapeCsvField(account.city ?? ''),
          _escapeCsvField(account.state ?? ''),
          _escapeCsvField(account.country ?? ''),
          _escapeCsvField(account.currency),
          _escapeCsvField(account.timeZone),
          _escapeCsvField(account.accountBalance?.toString() ?? '0'),
          _escapeCsvField(account.accountCBA?.toString() ?? '0'),
          _escapeCsvField(account.referenceTime.toIso8601String()),
          _escapeCsvField(account.notes ?? ''),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) return '';

    // Escape quotes and wrap in quotes if contains comma, quote, or newline
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }

    return value;
  }
}
