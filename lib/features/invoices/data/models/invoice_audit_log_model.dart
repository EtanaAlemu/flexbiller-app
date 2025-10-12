import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/invoice_audit_log.dart';

part 'invoice_audit_log_model.g.dart';

@JsonSerializable()
class InvoiceAuditLogModel {
  final String changeType;
  final String changeDate;
  final String objectType;
  final String objectId;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String userToken;
  final Map<String, dynamic>? history;

  const InvoiceAuditLogModel({
    required this.changeType,
    required this.changeDate,
    required this.objectType,
    required this.objectId,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    required this.userToken,
    this.history,
  });

  factory InvoiceAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceAuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceAuditLogModelToJson(this);

  factory InvoiceAuditLogModel.fromEntity(InvoiceAuditLog entity) {
    return InvoiceAuditLogModel(
      changeType: entity.changeType,
      changeDate: entity.changeDate,
      objectType: entity.objectType,
      objectId: entity.objectId,
      changedBy: entity.changedBy,
      reasonCode: entity.reasonCode,
      comments: entity.comments,
      userToken: entity.userToken,
      history: entity.history,
    );
  }

  InvoiceAuditLog toEntity() {
    return InvoiceAuditLog(
      changeType: changeType,
      changeDate: changeDate,
      objectType: objectType,
      objectId: objectId,
      changedBy: changedBy,
      reasonCode: reasonCode,
      comments: comments,
      userToken: userToken,
      history: history,
    );
  }
}
