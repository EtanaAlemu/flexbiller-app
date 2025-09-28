import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/plan.dart';
import 'plan_feature_model.dart';

part 'plan_model.g.dart';

@JsonSerializable()
class PlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle;
  final int trialDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: 'flexbillPlanFeatures')
  final List<PlanFeatureModel> flexbillPlanFeatures;

  const PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.trialDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.flexbillPlanFeatures,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanModelToJson(this);

  factory PlanModel.fromEntity(Plan entity) {
    return PlanModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      billingCycle: entity.billingCycle,
      trialDays: entity.trialDays,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      flexbillPlanFeatures: entity.flexbillPlanFeatures
          .map((feature) => PlanFeatureModel.fromEntity(feature))
          .toList(),
    );
  }

  Plan toEntity() {
    return Plan(
      id: id,
      name: name,
      description: description,
      price: price,
      billingCycle: billingCycle,
      trialDays: trialDays,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      flexbillPlanFeatures: flexbillPlanFeatures
          .map((feature) => feature.toEntity())
          .toList(),
    );
  }
}
