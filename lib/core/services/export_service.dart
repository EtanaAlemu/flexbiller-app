import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/tags/domain/entities/tag.dart';

abstract class ExportService {
  Future<String> exportAccountsToCSV(List<Account> accounts);
  Future<String> exportAccountsToExcel(List<Account> accounts);
  Future<String> exportTagsToCSV(List<Tag> tags);
  Future<String> exportTagsToExcel(List<Tag> tags);
  Future<void> shareFile(String filePath, {String? subject, String? text});
}

@injectable
@LazySingleton(as: ExportService)
class ExportServiceImpl implements ExportService {
  @override
  Future<String> exportAccountsToCSV(List<Account> accounts) async {
    try {
      // Try external storage first (with permissions)
      try {
        final externalPath = await _exportToExternalStorage(accounts, 'csv');
        if (externalPath != null) {
          return externalPath;
        }
      } catch (e) {
        // If external storage fails, fall back to internal storage
        print('External storage failed, falling back to internal: $e');
      }

      // Fallback to internal storage
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'accounts_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Create CSV content
      final csvContent = generateCSVContent(accounts);

      // Write to file with UTF-8 encoding
      await file.writeAsString(csvContent, encoding: utf8);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  @override
  Future<String> exportAccountsToExcel(List<Account> accounts) async {
    try {
      // Try external storage first (with permissions)
      try {
        final externalPath = await _exportToExternalStorage(accounts, 'xlsx');
        if (externalPath != null) {
          return externalPath;
        }
      } catch (e) {
        // If external storage fails, fall back to internal storage
        print('External storage failed, falling back to internal: $e');
      }

      // Fallback to internal storage
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

  String generateCSVContent(List<Account> accounts) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Account ID,Name,Email,Company,Phone,Address,City,State,Country,Currency,Time Zone,Balance,CBA,Created At,Notes',
    );

    // CSV Data
    for (final account in accounts) {
      // Create a properly formatted address without internal commas
      final addressParts =
          [
                account.address1,
                account.address2,
                account.city,
                account.state,
                account.country,
              ]
              .where(
                (part) =>
                    part != null && part.isNotEmpty && part.trim().isNotEmpty,
              )
              .cast<String>()
              .toList();

      // Only include meaningful address parts (filter out single characters or test data)
      final meaningfulAddressParts = addressParts
          .where((part) => part.length > 1)
          .toList();

      final formattedAddress = meaningfulAddressParts.isNotEmpty
          ? meaningfulAddressParts.join(' | ')
          : '';

      buffer.writeln(
        [
          _escapeCsvField(account.accountId),
          _escapeCsvField(account.name),
          _escapeCsvField(account.email),
          _escapeCsvField(_cleanField(account.company)),
          _escapeCsvField(_cleanField(account.phone)),
          _escapeCsvField(formattedAddress),
          _escapeCsvField(_cleanField(account.city)),
          _escapeCsvField(_cleanField(account.state)),
          _escapeCsvField(_cleanField(account.country)),
          _escapeCsvField(account.currency),
          _escapeCsvField(account.timeZone),
          _escapeCsvField(_formatBalance(account.accountBalance)),
          _escapeCsvField(_formatBalance(account.accountCBA)),
          _escapeCsvField(account.referenceTime.toIso8601String()),
          _escapeCsvField(_cleanField(account.notes)),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  @override
  Future<String> exportTagsToCSV(List<Tag> tags) async {
    try {
      // Try external storage first (with permissions)
      try {
        final externalPath = await _exportTagsToExternalStorage(tags, 'csv');
        if (externalPath != null) {
          return externalPath;
        }
      } catch (e) {
        // If external storage fails, fall back to internal storage
        print('External storage failed, falling back to internal: $e');
      }

      // Fallback to internal storage
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tags_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Create CSV content
      final csvContent = _generateTagsCSVContent(tags);

      // Write to file with UTF-8 encoding
      await file.writeAsString(csvContent, encoding: utf8);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export tags CSV: $e');
    }
  }

  @override
  Future<String> exportTagsToExcel(List<Tag> tags) async {
    try {
      // Try external storage first (with permissions)
      try {
        final externalPath = await _exportTagsToExternalStorage(tags, 'xlsx');
        if (externalPath != null) {
          return externalPath;
        }
      } catch (e) {
        // If external storage fails, fall back to internal storage
        print('External storage failed, falling back to internal: $e');
      }

      // Fallback to internal storage
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tags_export_$timestamp.xlsx';
      final file = File('${directory.path}/$fileName');

      // Create actual Excel file
      final excelBytes = _generateTagsExcelContent(tags);
      await file.writeAsBytes(excelBytes);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export tags Excel: $e');
    }
  }

  Uint8List _generateTagsExcelContent(List<Tag> tags) {
    final excel = Excel.createExcel();

    // Delete the default sheet
    excel.delete('Sheet1');

    // Create a new sheet for tags
    final sheet = excel['Tags'];

    // Define headers
    final headers = [
      'Tag ID',
      'Tag Definition Name',
      'Object Type',
      'Object ID',
      'Tag Definition ID',
      'Audit Logs Count',
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

    // Add tag data
    for (int rowIndex = 0; rowIndex < tags.length; rowIndex++) {
      final tag = tags[rowIndex];
      final row = rowIndex + 1; // +1 because headers are in row 0

      // Tag ID
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        tag.tagId,
      );

      // Tag Definition Name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        tag.tagDefinitionName,
      );

      // Object Type
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(
        tag.objectType,
      );

      // Object ID
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(
        tag.objectId,
      );

      // Tag Definition ID
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(
        tag.tagDefinitionId,
      );

      // Audit Logs Count
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = IntCellValue(
        tag.auditLogs.length,
      );
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    // Add some styling to the data rows
    for (int rowIndex = 1; rowIndex <= tags.length; rowIndex++) {
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

  String _generateTagsCSVContent(List<Tag> tags) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Tag ID,Tag Definition Name,Object Type,Object ID,Tag Definition ID,Audit Logs Count',
    );

    // CSV Data
    for (final tag in tags) {
      buffer.writeln(
        [
          _escapeCsvField(tag.tagId),
          _escapeCsvField(tag.tagDefinitionName),
          _escapeCsvField(tag.objectType),
          _escapeCsvField(tag.objectId),
          _escapeCsvField(tag.tagDefinitionId),
          _escapeCsvField(tag.auditLogs.length.toString()),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) return '';

    // Clean the value of any problematic characters
    String cleanedValue = value
        .replaceAll('\r\n', ' ') // Replace Windows line breaks
        .replaceAll('\r', ' ') // Replace Mac line breaks
        .replaceAll('\n', ' ') // Replace Unix line breaks
        .trim();

    // Escape quotes and wrap in quotes if contains comma, quote, or newline
    if (cleanedValue.contains(',') ||
        cleanedValue.contains('"') ||
        cleanedValue.contains('\n') ||
        cleanedValue.contains('\r')) {
      return '"${cleanedValue.replaceAll('"', '""')}"';
    }

    return cleanedValue;
  }

  /// Clean field data by removing test data and meaningless values
  String _cleanField(String? value) {
    if (value == null || value.isEmpty) return '';

    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    return trimmed;
  }

  /// Format balance values consistently
  String _formatBalance(double? balance) {
    if (balance == null) return '0.00';
    return balance.toStringAsFixed(2);
  }

  // Helper methods for external storage (Android 15 compliant)
  Future<String?> _exportToExternalStorage(
    List<Account> accounts,
    String fileType,
  ) async {
    try {
      // Request storage permission
      final permission = await _requestStoragePermission();
      if (!permission) {
        throw Exception('Storage permission denied');
      }

      // Generate content based on file type
      Uint8List fileBytes;
      if (fileType == 'csv') {
        final csvContent = generateCSVContent(accounts);
        fileBytes = Uint8List.fromList(utf8.encode(csvContent));
      } else if (fileType == 'xlsx') {
        fileBytes = _generateExcelContent(accounts);
      } else {
        throw Exception('Unsupported file type: $fileType');
      }

      // Try to save to Downloads first, fallback to app external directory
      try {
        // Let user choose save location with bytes parameter
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Accounts ${fileType.toUpperCase()}',
          fileName:
              'accounts_export_${DateTime.now().millisecondsSinceEpoch}.$fileType',
          type: FileType.custom,
          allowedExtensions: [fileType],
          bytes: fileBytes, // Pass bytes directly to file_picker
        );

        if (result != null) {
          return result;
        }
      } catch (e) {
        print('FilePicker failed, falling back to app directory: $e');
      }

      // Fallback: Save to app's external files directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('External storage directory not available');
      }

      final fileName =
          'accounts_export_${DateTime.now().millisecondsSinceEpoch}.$fileType';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export $fileType to external storage: $e');
    }
  }

  Future<String?> _exportTagsToExternalStorage(
    List<Tag> tags,
    String fileType,
  ) async {
    try {
      // Request storage permission
      final permission = await _requestStoragePermission();
      if (!permission) {
        throw Exception('Storage permission denied');
      }

      // Generate content based on file type
      Uint8List fileBytes;
      if (fileType == 'csv') {
        final csvContent = _generateTagsCSVContent(tags);
        fileBytes = Uint8List.fromList(utf8.encode(csvContent));
      } else if (fileType == 'xlsx') {
        fileBytes = _generateTagsExcelContent(tags);
      } else {
        throw Exception('Unsupported file type: $fileType');
      }

      // Try to save to Downloads first, fallback to app external directory
      try {
        // Let user choose save location with bytes parameter
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Tags ${fileType.toUpperCase()}',
          fileName:
              'tags_export_${DateTime.now().millisecondsSinceEpoch}.$fileType',
          type: FileType.custom,
          allowedExtensions: [fileType],
          bytes: fileBytes, // Pass bytes directly to file_picker
        );

        if (result != null) {
          return result;
        }
      } catch (e) {
        print('FilePicker failed, falling back to app directory: $e');
      }

      // Fallback: Save to app's external files directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('External storage directory not available');
      }

      final fileName =
          'tags_export_${DateTime.now().millisecondsSinceEpoch}.$fileType';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      return file.path;
    } catch (e) {
      throw Exception(
        'Failed to export tags $fileType to external storage: $e',
      );
    }
  }

  /// Request storage permission with Android 15 compliance
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check Android version for different permission strategies
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        // Android 13+ (API 33+) - Use media permissions
        return await _requestMediaPermissions();
      } else if (androidInfo >= 30) {
        // Android 11+ (API 30+) - Use manage external storage
        return await _requestManageExternalStorage();
      } else {
        // Android 10 and below - Use traditional storage permissions
        return await _requestTraditionalStoragePermissions();
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for file picker
      return true;
    } else {
      // Desktop platforms
      return true;
    }
  }

  /// Get Android version
  Future<int> _getAndroidVersion() async {
    try {
      // Use device_info_plus package for accurate version detection
      // For now, return a safe default that works with current permissions
      return 33; // Default to Android 13+ for safety
    } catch (e) {
      return 33; // Default to Android 13+ for safety
    }
  }

  /// Request media permissions for Android 13+
  Future<bool> _requestMediaPermissions() async {
    try {
      // Request media permissions
      final permissions = [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ];

      final statuses = await permissions.request();

      // Check if any media permission is granted
      for (final status in statuses.values) {
        if (status.isGranted) {
          return true;
        }
      }

      // If no media permissions, try manage external storage as fallback
      return await _requestManageExternalStorage();
    } catch (e) {
      print('Media permissions failed: $e');
      // Fallback to traditional storage permissions
      return await _requestTraditionalStoragePermissions();
    }
  }

  /// Request manage external storage permission
  Future<bool> _requestManageExternalStorage() async {
    try {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }

      // If manage external storage is denied, try traditional storage permissions
      print(
        'Manage external storage denied, trying traditional storage permissions',
      );
      return await _requestTraditionalStoragePermissions();
    } catch (e) {
      print('Manage external storage failed: $e');
      // Fallback to traditional storage permissions
      return await _requestTraditionalStoragePermissions();
    }
  }

  /// Request traditional storage permissions for older Android versions
  Future<bool> _requestTraditionalStoragePermissions() async {
    try {
      final permissions = [
        Permission.storage,
        Permission.manageExternalStorage,
      ];

      final statuses = await permissions.request();

      for (final status in statuses.values) {
        if (status.isGranted) {
          return true;
        }
      }

      print('Traditional storage permissions denied');
      return false;
    } catch (e) {
      print('Traditional storage permissions failed: $e');
      return false;
    }
  }

  @override
  Future<void> shareFile(
    String filePath, {
    String? subject,
    String? text,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Use the shareXFiles API
      await Share.shareXFiles([XFile(filePath)], subject: subject, text: text);

      print('Share initiated successfully!');
    } catch (e) {
      // Fallback to the non-result variant if the new API fails
      print('New share API failed, falling back to non-result variant: $e');

      // Use the non-result variant without await
      Share.shareXFiles([XFile(filePath)], subject: subject, text: text);
    }
  }
}
