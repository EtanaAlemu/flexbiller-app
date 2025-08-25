// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_custom_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountCustomFieldModel _$AccountCustomFieldModelFromJson(
  Map<String, dynamic> json,
) => AccountCustomFieldModel(
  customFieldId: json['customFieldId'] as String,
  objectId: json['objectId'] as String,
  objectType: json['objectType'] as String,
  name: json['name'] as String,
  value: json['value'] as String,
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$AccountCustomFieldModelToJson(
  AccountCustomFieldModel instance,
) => <String, dynamic>{
  'customFieldId': instance.customFieldId,
  'objectId': instance.objectId,
  'objectType': instance.objectType,
  'name': instance.name,
  'value': instance.value,
  'auditLogs': instance.auditLogs,
};

CustomFieldAuditLogModel _$CustomFieldAuditLogModelFromJson(
  Map<String, dynamic> json,
) => CustomFieldAuditLogModel(
  changeType: json['changeType'] as String,
  changeDate: DateTime.parse(json['changeDate'] as String),
  changedBy: json['changedBy'] as String,
  reasonCode: json['reasonCode'] as String?,
  comments: json['comments'] as String?,
  objectType: json['objectType'] as String?,
  userToken: json['objectId'] as String?,
);

Map<String, dynamic> _$CustomFieldAuditLogModelToJson(
  CustomFieldAuditLogModel instance,
) => <String, dynamic>{
  'changeType': instance.changeType,
  'changeDate': instance.changeDate.toIso8601String(),
  'changedBy': instance.changedBy,
  'reasonCode': instance.reasonCode,
  'comments': instance.comments,
  'objectType': instance.objectType,
  'objectId': instance.userToken,
};

AccountCustomFieldCreationResponseModel
_$AccountCustomFieldCreationResponseModelFromJson(Map<String, dynamic> json) =>
    AccountCustomFieldCreationResponseModel(
      message: json['message'] as String,
      accountId: json['accountId'] as String,
      customFields: (json['customFields'] as List<dynamic>)
          .map((e) => CustomFieldDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountCustomFieldCreationResponseModelToJson(
  AccountCustomFieldCreationResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'accountId': instance.accountId,
  'customFields': instance.customFields,
};

CustomFieldDataModel _$CustomFieldDataModelFromJson(
  Map<String, dynamic> json,
) => CustomFieldDataModel(
  name: json['name'] as String,
  value: json['value'] as String,
);

Map<String, dynamic> _$CustomFieldDataModelToJson(
  CustomFieldDataModel instance,
) => <String, dynamic>{'name': instance.name, 'value': instance.value};
