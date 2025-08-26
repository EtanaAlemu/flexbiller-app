import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subscription_custom_field.dart';

part 'subscription_custom_field_model.g.dart';

@JsonSerializable()
class SubscriptionCustomFieldModel {
  @JsonKey(name: 'customFieldId')
  final String? customFieldId;

  @JsonKey(name: 'objectId')
  final String? objectId;

  @JsonKey(name: 'objectType')
  final String? objectType;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'value')
  final String value;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  const SubscriptionCustomFieldModel({
    this.customFieldId,
    this.objectId,
    this.objectType,
    required this.name,
    required this.value,
    this.auditLogs = const [],
  });

  factory SubscriptionCustomFieldModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCustomFieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionCustomFieldModelToJson(this);

  SubscriptionCustomField toEntity() {
    return SubscriptionCustomField(
      customFieldId: customFieldId,
      objectId: objectId,
      objectType: objectType,
      name: name,
      value: value,
      auditLogs: auditLogs,
    );
  }
}

