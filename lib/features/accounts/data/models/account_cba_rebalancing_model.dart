import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_cba_rebalancing.dart';

part 'account_cba_rebalancing_model.g.dart';

@JsonSerializable()
class AccountCbaRebalancingModel {
  @JsonKey(name: 'message')
  final String message;
  
  @JsonKey(name: 'accountId')
  final String accountId;
  
  @JsonKey(name: 'result')
  final String result;

  const AccountCbaRebalancingModel({
    required this.message,
    required this.accountId,
    required this.result,
  });

  factory AccountCbaRebalancingModel.fromJson(Map<String, dynamic> json) =>
      _$AccountCbaRebalancingModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountCbaRebalancingModelToJson(this);

  // Convert from domain entity to data model
  factory AccountCbaRebalancingModel.fromEntity(AccountCbaRebalancing entity) {
    return AccountCbaRebalancingModel(
      message: entity.message,
      accountId: entity.accountId,
      result: entity.result,
    );
  }

  // Convert from data model to domain entity
  AccountCbaRebalancing toEntity() {
    return AccountCbaRebalancing(
      message: message,
      accountId: accountId,
      result: result,
    );
  }
}
