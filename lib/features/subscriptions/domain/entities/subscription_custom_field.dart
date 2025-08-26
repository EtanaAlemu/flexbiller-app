import 'package:equatable/equatable.dart';

class SubscriptionCustomField extends Equatable {
  final String? customFieldId;
  final String? objectId;
  final String? objectType;
  final String name;
  final String value;
  final List<Map<String, dynamic>> auditLogs;

  const SubscriptionCustomField({
    this.customFieldId,
    this.objectId,
    this.objectType,
    required this.name,
    required this.value,
    this.auditLogs = const [],
  });

  @override
  List<Object?> get props => [
        customFieldId,
        objectId,
        objectType,
        name,
        value,
        auditLogs,
      ];

  @override
  String toString() {
    return 'SubscriptionCustomField(name: $name, value: $value, customFieldId: $customFieldId)';
  }

  SubscriptionCustomField copyWith({
    String? customFieldId,
    String? objectId,
    String? objectType,
    String? name,
    String? value,
    List<Map<String, dynamic>>? auditLogs,
  }) {
    return SubscriptionCustomField(
      customFieldId: customFieldId ?? this.customFieldId,
      objectId: objectId ?? this.objectId,
      objectType: objectType ?? this.objectType,
      name: name ?? this.name,
      value: value ?? this.value,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

