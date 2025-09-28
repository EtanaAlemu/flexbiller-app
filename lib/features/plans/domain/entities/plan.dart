import 'plan_feature.dart';

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle;
  final int trialDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlanFeature> flexbillPlanFeatures;

  const Plan({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.billingCycle == billingCycle &&
        other.trialDays == trialDays &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _listEquals(other.flexbillPlanFeatures, flexbillPlanFeatures);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        billingCycle.hashCode ^
        trialDays.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        flexbillPlanFeatures.hashCode;
  }

  @override
  String toString() {
    return 'Plan(id: $id, name: $name, description: $description, price: $price, billingCycle: $billingCycle, trialDays: $trialDays, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, flexbillPlanFeatures: $flexbillPlanFeatures)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

