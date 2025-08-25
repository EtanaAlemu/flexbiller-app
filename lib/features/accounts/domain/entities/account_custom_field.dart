import 'package:equatable/equatable.dart';

class AccountCustomField extends Equatable {
  final String customFieldId;
  final String accountId;
  final String name;
  final String value;
  final List<CustomFieldAuditLog> auditLogs;

  const AccountCustomField({
    required this.customFieldId,
    required this.accountId,
    required this.name,
    required this.value,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [customFieldId, accountId, name, value, auditLogs];

  AccountCustomField copyWith({
    String? customFieldId,
    String? accountId,
    String? name,
    String? value,
    List<CustomFieldAuditLog>? auditLogs,
  }) {
    return AccountCustomField(
      customFieldId: customFieldId ?? this.customFieldId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      value: value ?? this.value,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }

  // Helper getters
  bool get hasAuditLogs => auditLogs.isNotEmpty;
  bool get hasValue => value.isNotEmpty;
  String get displayName => name.isNotEmpty ? name : 'Unnamed Field';
  String get displayValue => value.isNotEmpty ? value : 'No value set';
}

class CustomFieldAuditLog extends Equatable {
  final String changeType;
  final DateTime changeDate;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String? objectType;
  final String? objectId;
  final String? userToken;

  const CustomFieldAuditLog({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    this.objectType,
    this.objectId,
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
        objectId,
        userToken,
      ];

  // Helper getters
  bool get isInsert => changeType.toUpperCase() == 'INSERT';
  bool get isUpdate => changeType.toUpperCase() == 'UPDATE';
  bool get isDelete => changeType.toUpperCase() == 'DELETE';
  bool get hasReason => reasonCode != null && reasonCode!.isNotEmpty;
  bool get hasComments => comments != null && comments!.isNotEmpty;

  String get formattedChangeDate {
    final now = DateTime.now();
    final difference = now.difference(changeDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get changeTypeDisplay {
    switch (changeType.toUpperCase()) {
      case 'INSERT':
        return 'Created';
      case 'UPDATE':
        return 'Updated';
      case 'DELETE':
        return 'Deleted';
      default:
        return changeType;
    }
  }

  String get changeTypeIcon {
    switch (changeType.toUpperCase()) {
      case 'INSERT':
        return 'add_circle';
      case 'UPDATE':
        return 'edit';
      case 'DELETE':
        return 'delete';
      default:
        return 'info';
    }
  }

  String get changeTypeColor {
    switch (changeType.toUpperCase()) {
      case 'INSERT':
        return '#4CAF50'; // Green
      case 'UPDATE':
        return '#2196F3'; // Blue
      case 'DELETE':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }
}
