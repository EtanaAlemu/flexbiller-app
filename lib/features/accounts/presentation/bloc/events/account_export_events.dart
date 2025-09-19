import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

/// Base class for export events
abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to export accounts
class ExportAccounts extends ExportEvent {
  final List<Account> accounts;
  final String format; // 'excel' or 'csv'

  const ExportAccounts({required this.accounts, required this.format});

  @override
  List<Object?> get props => [accounts, format];
}

class ExportSelectedAccounts extends ExportEvent {
  final List<String> accountIds;
  final String format; // 'excel' or 'csv'

  const ExportSelectedAccounts({
    required this.accountIds,
    required this.format,
  });

  @override
  List<Object?> get props => [accountIds, format];
}

/// Event to share a file
class ShareFile extends ExportEvent {
  final String filePath;
  final String fileName;

  const ShareFile({required this.filePath, required this.fileName});

  @override
  List<Object?> get props => [filePath, fileName];
}

/// Event to bulk export selected accounts
class BulkExportAccounts extends ExportEvent {
  final String format;

  const BulkExportAccounts(this.format);

  @override
  List<Object?> get props => [format];
}
