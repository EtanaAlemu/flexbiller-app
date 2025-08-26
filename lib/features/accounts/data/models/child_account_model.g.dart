// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildAccountModel _$ChildAccountModelFromJson(Map<String, dynamic> json) =>
    ChildAccountModel(
      name: json['name'] as String,
      email: json['email'] as String,
      currency: json['currency'] as String,
      isPaymentDelegatedToParent: json['isPaymentDelegatedToParent'] as bool,
      parentAccountId: json['parentAccountId'] as String,
    );

Map<String, dynamic> _$ChildAccountModelToJson(ChildAccountModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'currency': instance.currency,
      'isPaymentDelegatedToParent': instance.isPaymentDelegatedToParent,
      'parentAccountId': instance.parentAccountId,
    };
