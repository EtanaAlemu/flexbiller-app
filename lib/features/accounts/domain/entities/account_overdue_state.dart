import 'package:equatable/equatable.dart';

class AccountOverdueState extends Equatable {
  final String name;
  final String externalMessage;
  final bool isDisableEntitlementAndChangesBlocked;
  final bool isBlockChanges;
  final bool isClearState;
  final int? reevaluationIntervalDays;

  const AccountOverdueState({
    required this.name,
    required this.externalMessage,
    required this.isDisableEntitlementAndChangesBlocked,
    required this.isBlockChanges,
    required this.isClearState,
    this.reevaluationIntervalDays,
  });

  @override
  List<Object?> get props => [
        name,
        externalMessage,
        isDisableEntitlementAndChangesBlocked,
        isBlockChanges,
        isClearState,
        reevaluationIntervalDays,
      ];
}
