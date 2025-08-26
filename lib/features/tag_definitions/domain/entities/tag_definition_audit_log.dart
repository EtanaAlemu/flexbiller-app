class TagDefinitionAuditLog {
  final String changeType;
  final DateTime changeDate;
  final String objectType;
  final String objectId;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String userToken;
  final TagDefinitionHistory history;

  const TagDefinitionAuditLog({
    required this.changeType,
    required this.changeDate,
    required this.objectType,
    required this.objectId,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    required this.userToken,
    required this.history,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagDefinitionAuditLog &&
        other.changeType == changeType &&
        other.changeDate == changeDate &&
        other.objectId == objectId &&
        other.userToken == userToken;
  }

  @override
  int get hashCode => Object.hash(changeType, changeDate, objectId, userToken);

  @override
  String toString() {
    return 'TagDefinitionAuditLog(changeType: $changeType, changeDate: $changeDate, objectId: $objectId, changedBy: $changedBy)';
  }
}

class TagDefinitionHistory {
  final String? id;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int recordId;
  final int accountRecordId;
  final int tenantRecordId;
  final String name;
  final String applicableObjectTypes;
  final String description;
  final bool isActive;
  final String tableName;
  final String historyTableName;

  const TagDefinitionHistory({
    this.id,
    required this.createdDate,
    required this.updatedDate,
    required this.recordId,
    required this.accountRecordId,
    required this.tenantRecordId,
    required this.name,
    required this.applicableObjectTypes,
    required this.description,
    required this.isActive,
    required this.tableName,
    required this.historyTableName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagDefinitionHistory &&
        other.recordId == recordId &&
        other.name == name &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode => Object.hash(recordId, name, createdDate);

  @override
  String toString() {
    return 'TagDefinitionHistory(name: $name, recordId: $recordId, isActive: $isActive)';
  }
}
