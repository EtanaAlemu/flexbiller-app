import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_blocking_state.dart';

part 'account_blocking_state_model.g.dart';

@JsonSerializable()
class AccountBlockingStateModel {
  @JsonKey(name: 'stateName')
  final String stateName;
  final String service;
  @JsonKey(name: 'isBlockChange')
  final bool isBlockChange;
  @JsonKey(name: 'isBlockEntitlement')
  final bool isBlockEntitlement;
  @JsonKey(name: 'isBlockBilling')
  final bool isBlockBilling;
  @JsonKey(name: 'effectiveDate')
  final DateTime effectiveDate;
  final String type;

  const AccountBlockingStateModel({
    required this.stateName,
    required this.service,
    required this.isBlockChange,
    required this.isBlockEntitlement,
    required this.isBlockBilling,
    required this.effectiveDate,
    required this.type,
  });

  factory AccountBlockingStateModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBlockingStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBlockingStateModelToJson(this);

  factory AccountBlockingStateModel.fromEntity(AccountBlockingState entity) {
    return AccountBlockingStateModel(
      stateName: entity.stateName,
      service: entity.service,
      isBlockChange: entity.isBlockChange,
      isBlockEntitlement: entity.isBlockEntitlement,
      isBlockBilling: entity.isBlockBilling,
      effectiveDate: entity.effectiveDate,
      type: entity.type,
    );
  }

  AccountBlockingState toEntity() {
    return AccountBlockingState(
      stateName: stateName,
      service: service,
      isBlockChange: isBlockChange,
      isBlockEntitlement: isBlockEntitlement,
      isBlockBilling: isBlockBilling,
      effectiveDate: effectiveDate,
      type: type,
    );
  }
}
