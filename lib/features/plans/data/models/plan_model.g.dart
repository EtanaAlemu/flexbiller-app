// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => PlanModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  billingCycle: json['billingCycle'] as String,
  trialDays: (json['trialDays'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  flexbillPlanFeatures: (json['flexbillPlanFeatures'] as List<dynamic>)
      .map((e) => PlanFeatureModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'billingCycle': instance.billingCycle,
  'trialDays': instance.trialDays,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'flexbillPlanFeatures': instance.flexbillPlanFeatures,
};
