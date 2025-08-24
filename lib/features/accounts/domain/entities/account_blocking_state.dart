import 'package:equatable/equatable.dart';

class AccountBlockingState extends Equatable {
  final String stateName;
  final String service;
  final bool isBlockChange;
  final bool isBlockEntitlement;
  final bool isBlockBilling;
  final DateTime effectiveDate;

  const AccountBlockingState({
    required this.stateName,
    required this.service,
    required this.isBlockChange,
    required this.isBlockEntitlement,
    required this.isBlockBilling,
    required this.effectiveDate,
  });

  @override
  List<Object?> get props => [
        stateName,
        service,
        isBlockChange,
        isBlockEntitlement,
        isBlockBilling,
        effectiveDate,
      ];

  AccountBlockingState copyWith({
    String? stateName,
    String? service,
    bool? isBlockChange,
    bool? isBlockEntitlement,
    bool? isBlockBilling,
    DateTime? effectiveDate,
  }) {
    return AccountBlockingState(
      stateName: stateName ?? this.stateName,
      service: service ?? this.service,
      isBlockChange: isBlockChange ?? this.isBlockChange,
      isBlockEntitlement: isBlockEntitlement ?? this.isBlockEntitlement,
      isBlockBilling: isBlockBilling ?? this.isBlockBilling,
      effectiveDate: effectiveDate ?? this.effectiveDate,
    );
  }
}
