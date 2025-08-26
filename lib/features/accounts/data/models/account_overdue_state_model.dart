import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_overdue_state.dart';

part 'account_overdue_state_model.g.dart';

@JsonSerializable()
class AccountOverdueStateModel {
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'externalMessage')
  final String externalMessage;
  
  @JsonKey(name: 'isDisableEntitlementAndChangesBlocked')
  final bool isDisableEntitlementAndChangesBlocked;
  
  @JsonKey(name: 'isBlockChanges')
  final bool isBlockChanges;
  
  @JsonKey(name: 'isClearState')
  final bool isClearState;
  
  @JsonKey(name: 'reevaluationIntervalDays')
  final int? reevaluationIntervalDays;

  const AccountOverdueStateModel({
    required this.name,
    required this.externalMessage,
    required this.isDisableEntitlementAndChangesBlocked,
    required this.isBlockChanges,
    required this.isClearState,
    this.reevaluationIntervalDays,
  });

  factory AccountOverdueStateModel.fromJson(Map<String, dynamic> json) =>
      _$AccountOverdueStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountOverdueStateModelToJson(this);

  // Convert from domain entity to data model
  factory AccountOverdueStateModel.fromEntity(AccountOverdueState entity) {
    return AccountOverdueStateModel(
      name: entity.name,
      externalMessage: entity.externalMessage,
      isDisableEntitlementAndChangesBlocked: entity.isDisableEntitlementAndChangesBlocked,
      isBlockChanges: entity.isBlockChanges,
      isClearState: entity.isClearState,
      reevaluationIntervalDays: entity.reevaluationIntervalDays,
    );
  }

  // Convert from data model to domain entity
  AccountOverdueState toEntity() {
    return AccountOverdueState(
      name: name,
      externalMessage: externalMessage,
      isDisableEntitlementAndChangesBlocked: isDisableEntitlementAndChangesBlocked,
      isBlockChanges: isBlockChanges,
      isClearState: isClearState,
      reevaluationIntervalDays: reevaluationIntervalDays,
    );
  }
}
