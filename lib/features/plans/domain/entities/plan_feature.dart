class PlanFeature {
  final String id;
  final String planId;
  final String featureName;
  final String featureValue;
  final DateTime createdAt;

  const PlanFeature({
    required this.id,
    required this.planId,
    required this.featureName,
    required this.featureValue,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanFeature &&
        other.id == id &&
        other.planId == planId &&
        other.featureName == featureName &&
        other.featureValue == featureValue &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        featureName.hashCode ^
        featureValue.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'PlanFeature(id: $id, planId: $planId, featureName: $featureName, featureValue: $featureValue, createdAt: $createdAt)';
  }
}

