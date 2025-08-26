// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_export_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountExportModel _$AccountExportModelFromJson(Map<String, dynamic> json) =>
    AccountExportModel(
      accountId: json['accountId'] as String,
      exportId: json['exportId'] as String,
      status: json['status'] as String,
      format: json['format'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      expiresAt: json['expiresAt'] as String?,
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$AccountExportModelToJson(AccountExportModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'exportId': instance.exportId,
      'status': instance.status,
      'format': instance.format,
      'createdAt': instance.createdAt,
      'completedAt': instance.completedAt,
      'downloadUrl': instance.downloadUrl,
      'fileSize': instance.fileSize,
      'expiresAt': instance.expiresAt,
      'auditLogs': instance.auditLogs,
    };
