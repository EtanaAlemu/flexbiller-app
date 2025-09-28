// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_feature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanFeatureModel _$PlanFeatureModelFromJson(Map<String, dynamic> json) =>
    PlanFeatureModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      featureName: json['featureName'] as String,
      featureValue: json['featureValue'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PlanFeatureModelToJson(PlanFeatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'featureName': instance.featureName,
      'featureValue': instance.featureValue,
      'createdAt': instance.createdAt.toIso8601String(),
    };
