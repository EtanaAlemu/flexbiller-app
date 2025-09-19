import 'package:equatable/equatable.dart';

/// Base class for export states
abstract class AccountExportState extends Equatable {
  const AccountExportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AccountExportInitial extends AccountExportState {
  const AccountExportInitial();
}

/// Export in progress state
class AccountsExporting extends AccountExportState {
  final int totalAccounts;
  final int exportedCount;
  final String format;

  const AccountsExporting({
    required this.totalAccounts,
    required this.exportedCount,
    required this.format,
  });

  @override
  List<Object?> get props => [totalAccounts, exportedCount, format];
}

/// Export success state
class AccountsExportSuccess extends AccountExportState {
  final String filePath;
  final String fileName;
  final int exportedCount;

  const AccountsExportSuccess({
    required this.filePath,
    required this.fileName,
    required this.exportedCount,
  });

  @override
  List<Object?> get props => [filePath, fileName, exportedCount];
}

/// Export failure state
class AccountsExportFailure extends AccountExportState {
  final String message;

  const AccountsExportFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// File sharing in progress state
class FileSharingInProgress extends AccountExportState {
  final String filePath;

  const FileSharingInProgress({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// File sharing success state
class FileSharingSuccess extends AccountExportState {
  final String filePath;

  const FileSharingSuccess({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// File sharing failure state
class FileSharingFailure extends AccountExportState {
  final String message;

  const FileSharingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
