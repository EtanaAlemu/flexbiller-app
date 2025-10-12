class InvoiceAuditLog {
  final String changeType;
  final String changeDate;
  final String objectType;
  final String objectId;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String userToken;
  final Map<String, dynamic>? history;

  const InvoiceAuditLog({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceAuditLog &&
        other.changeType == changeType &&
        other.changeDate == changeDate &&
        other.objectType == objectType &&
        other.objectId == objectId &&
        other.changedBy == changedBy &&
        other.reasonCode == reasonCode &&
        other.comments == comments &&
        other.userToken == userToken &&
        _mapEquals(other.history, history);
  }

  @override
  int get hashCode {
    return changeType.hashCode ^
        changeDate.hashCode ^
        objectType.hashCode ^
        objectId.hashCode ^
        changedBy.hashCode ^
        reasonCode.hashCode ^
        comments.hashCode ^
        userToken.hashCode ^
        history.hashCode;
  }

  @override
  String toString() {
    return 'InvoiceAuditLog(changeType: $changeType, changeDate: $changeDate, objectType: $objectType, objectId: $objectId, changedBy: $changedBy, reasonCode: $reasonCode, comments: $comments, userToken: $userToken, history: $history)';
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

