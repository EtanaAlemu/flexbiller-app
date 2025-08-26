import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_export.dart';

part 'account_export_model.g.dart';

@JsonSerializable()
class AccountExportModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'exportId')
  final String exportId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'format')
  final String format;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'completedAt')
  final String? completedAt;

  @JsonKey(name: 'downloadUrl')
  final String? downloadUrl;

  @JsonKey(name: 'fileSize')
  final int? fileSize;

  @JsonKey(name: 'expiresAt')
  final String? expiresAt;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  const AccountExportModel({
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

  factory AccountExportModel.fromJson(Map<String, dynamic> json) =>
      _$AccountExportModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountExportModelToJson(this);

  // Convert from domain entity to data model
  factory AccountExportModel.fromEntity(AccountExport entity) {
    return AccountExportModel(
      accountId: entity.accountId,
      exportId: entity.exportId,
      status: entity.status,
      format: entity.format,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      downloadUrl: entity.downloadUrl,
      fileSize: entity.fileSize,
      expiresAt: entity.expiresAt,
      auditLogs: entity.auditLogs
          .map((log) => {
                'changeType': log.changeType,
                'changeDate': log.changeDate.toIso8601String(),
                'changedBy': log.changedBy,
                'reasonCode': log.reasonCode,
                'comments': log.comments,
                'objectType': log.objectType,
                'userToken': log.userToken,
              })
          .toList(),
    );
  }

  // Convert from data model to domain entity
  AccountExport toEntity() {
    return AccountExport(
      accountId: accountId,
      exportId: exportId,
      status: status,
      format: format,
      createdAt: createdAt,
      completedAt: completedAt,
      downloadUrl: downloadUrl,
      fileSize: fileSize,
      expiresAt: expiresAt,
      auditLogs: auditLogs
          .map((log) => ExportAuditLog(
                changeType: log['changeType'] ?? '',
                changeDate: DateTime.tryParse(log['changeDate'] ?? '') ?? DateTime.now(),
                changedBy: log['changedBy'] ?? '',
                reasonCode: log['reasonCode'],
                comments: log['comments'],
                objectType: log['objectType'],
                userToken: log['userToken'],
              ))
          .toList(),
    );
  }
}
