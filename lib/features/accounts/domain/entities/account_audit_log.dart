import 'package:equatable/equatable.dart';

class AccountAuditLog extends Equatable {
  final String id;
  final String accountId;
  final String userId;
  final String userName;
  final String action;
  final String entityType;
  final String entityId;
  final String oldValue;
  final String newValue;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  const AccountAuditLog({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.oldValue,
    required this.newValue,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        userId,
        userName,
        action,
        entityType,
        entityId,
        oldValue,
        newValue,
        description,
        timestamp,
        ipAddress,
        userAgent,
        metadata,
      ];

  AccountAuditLog copyWith({
    String? id,
    String? accountId,
    String? userId,
    String? userName,
    String? action,
    String? entityType,
    String? entityId,
    String? oldValue,
    String? newValue,
    String? description,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) {
    return AccountAuditLog(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      metadata: metadata ?? this.metadata,
    );
  }
}
