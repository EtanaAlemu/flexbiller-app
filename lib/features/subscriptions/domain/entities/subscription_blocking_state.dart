import 'package:equatable/equatable.dart';

class SubscriptionBlockingState extends Equatable {
  final String? stateName;
  final String? service;
  final bool? isBlockChange;
  final bool? isBlockEntitlement;
  final bool? isBlockBilling;
  final DateTime? effectiveDate;
  final String? type;

  const SubscriptionBlockingState({
    this.stateName,
    this.service,
    this.isBlockChange,
    this.isBlockEntitlement,
    this.isBlockBilling,
    this.effectiveDate,
    this.type,
  });

  @override
  List<Object?> get props => [
        stateName,
        service,
        isBlockChange,
        isBlockEntitlement,
        isBlockBilling,
        effectiveDate,
        type,
      ];

  @override
  String toString() {
    return 'SubscriptionBlockingState(stateName: $stateName, service: $service, type: $type)';
  }

  SubscriptionBlockingState copyWith({
    String? stateName,
    String? service,
    bool? isBlockChange,
    bool? isBlockEntitlement,
    bool? isBlockBilling,
    DateTime? effectiveDate,
    String? type,
  }) {
    return SubscriptionBlockingState(
      stateName: stateName ?? this.stateName,
      service: service ?? this.service,
      isBlockChange: isBlockChange ?? this.isBlockChange,
      isBlockEntitlement: isBlockEntitlement ?? this.isBlockEntitlement,
      isBlockBilling: isBlockBilling ?? this.isBlockBilling,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      type: type ?? this.type,
    );
  }
}
