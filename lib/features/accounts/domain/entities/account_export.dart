import 'package:equatable/equatable.dart';

class AccountExport extends Equatable {
  final String accountId;
  final String exportId;
  final String status;
  final String format;
  final String createdAt;
  final String? completedAt;
  final String? downloadUrl;
  final int? fileSize;
  final String? expiresAt;
  final List<ExportAuditLog> auditLogs;

  const AccountExport({
    required this.accountId,
    required this.exportId,
    required this.status,
    required this.format,
    required this.createdAt,
    this.completedAt,
    this.downloadUrl,
    this.fileSize,
    this.expiresAt,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        accountId,
        exportId,
        status,
        format,
        createdAt,
        completedAt,
        downloadUrl,
        fileSize,
        expiresAt,
        auditLogs,
      ];
}

class ExportAuditLog extends Equatable {
  final String changeType;
  final DateTime changeDate;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String? objectType;
  final String? userToken;

  const ExportAuditLog({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    this.objectType,
    this.userToken,
  });

  @override
  List<Object?> get props => [
        changeType,
        changeDate,
        changedBy,
        reasonCode,
        comments,
        objectType,
        userToken,
      ];
}
