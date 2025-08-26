import 'package:equatable/equatable.dart';

class SubscriptionAuditLog extends Equatable {
  final String? changeType;
  final DateTime? changeDate;
  final String? objectType;
  final String? objectId;
  final String? changedBy;
  final String? reasonCode;
  final String? comments;
  final String? userToken;
  final SubscriptionAuditHistory? history;

  const SubscriptionAuditLog({
    this.changeType,
    this.changeDate,
    this.objectType,
    this.objectId,
    this.changedBy,
    this.reasonCode,
    this.comments,
    this.userToken,
    this.history,
  });

  @override
  List<Object?> get props => [
        changeType,
        changeDate,
        objectType,
        objectId,
        changedBy,
        reasonCode,
        comments,
        userToken,
        history,
      ];

  @override
  String toString() {
    return 'SubscriptionAuditLog(changeType: $changeType, changeDate: $changeDate, objectType: $objectType)';
  }

  SubscriptionAuditLog copyWith({
    String? changeType,
    DateTime? changeDate,
    String? objectType,
    String? objectId,
    String? changedBy,
    String? reasonCode,
    String? comments,
    String? userToken,
    SubscriptionAuditHistory? history,
  }) {
    return SubscriptionAuditLog(
      changeType: changeType ?? this.changeType,
      changeDate: changeDate ?? this.changeDate,
      objectType: objectType ?? this.objectType,
      objectId: objectId ?? this.objectId,
      changedBy: changedBy ?? this.changedBy,
      reasonCode: reasonCode ?? this.reasonCode,
      comments: comments ?? this.comments,
      userToken: userToken ?? this.userToken,
      history: history ?? this.history,
    );
  }
}

class SubscriptionAuditHistory extends Equatable {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final int? recordId;
  final int? accountRecordId;
  final int? tenantRecordId;
  final String? bundleId;
  final String? externalKey;
  final String? category;
  final DateTime? startDate;
  final DateTime? bundleStartDate;
  final DateTime? chargedThroughDate;
  final bool? migrated;
  final String? tableName;
  final String? historyTableName;

  const SubscriptionAuditHistory({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.recordId,
    this.accountRecordId,
    this.tenantRecordId,
    this.bundleId,
    this.externalKey,
    this.category,
    this.startDate,
    this.bundleStartDate,
    this.chargedThroughDate,
    this.migrated,
    this.tableName,
    this.historyTableName,
  });

  @override
  List<Object?> get props => [
        id,
        createdDate,
        updatedDate,
        recordId,
        accountRecordId,
        tenantRecordId,
        bundleId,
        externalKey,
        category,
        startDate,
        bundleStartDate,
        chargedThroughDate,
        migrated,
        tableName,
        historyTableName,
      ];

  @override
  String toString() {
    return 'SubscriptionAuditHistory(changeType: $category, recordId: $recordId, tableName: $tableName)';
  }

  SubscriptionAuditHistory copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? recordId,
    int? accountRecordId,
    int? tenantRecordId,
    String? bundleId,
    String? externalKey,
    String? category,
    DateTime? startDate,
    DateTime? bundleStartDate,
    DateTime? chargedThroughDate,
    bool? migrated,
    String? tableName,
    String? historyTableName,
  }) {
    return SubscriptionAuditHistory(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      recordId: recordId ?? this.recordId,
      accountRecordId: accountRecordId ?? this.accountRecordId,
      tenantRecordId: tenantRecordId ?? this.tenantRecordId,
      bundleId: bundleId ?? this.bundleId,
      externalKey: externalKey ?? this.externalKey,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      bundleStartDate: bundleStartDate ?? this.bundleStartDate,
      chargedThroughDate: chargedThroughDate ?? this.chargedThroughDate,
      migrated: migrated ?? this.migrated,
      tableName: tableName ?? this.tableName,
      historyTableName: historyTableName ?? this.historyTableName,
    );
  }
}
