import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/plan_feature.dart';

part 'plan_feature_model.g.dart';

@JsonSerializable()
class PlanFeatureModel extends PlanFeature {
  const PlanFeatureModel({
    required super.id,
    required super.planId,
    required super.featureName,
    required super.featureValue,
    required super.createdAt,
  });

  factory PlanFeatureModel.fromJson(Map<String, dynamic> json) =>
      _$PlanFeatureModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanFeatureModelToJson(this);

  factory PlanFeatureModel.fromEntity(PlanFeature entity) {
    return PlanFeatureModel(
      id: entity.id,
      planId: entity.planId,
      featureName: entity.featureName,
      featureValue: entity.featureValue,
      createdAt: entity.createdAt,
    );
  }

  PlanFeature toEntity() {
    return PlanFeature(
      id: id,
      planId: planId,
      featureName: featureName,
      featureValue: featureValue,
      createdAt: createdAt,
    );
  }
}

