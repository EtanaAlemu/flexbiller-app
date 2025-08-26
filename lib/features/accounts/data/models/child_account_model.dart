import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/child_account.dart';

part 'child_account_model.g.dart';

@JsonSerializable()
class ChildAccountModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'isPaymentDelegatedToParent')
  final bool isPaymentDelegatedToParent;

  @JsonKey(name: 'parentAccountId')
  final String parentAccountId;

  const ChildAccountModel({
    required this.name,
    required this.email,
    required this.currency,
    required this.isPaymentDelegatedToParent,
    required this.parentAccountId,
  });

  factory ChildAccountModel.fromJson(Map<String, dynamic> json) =>
      _$ChildAccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildAccountModelToJson(this);

  // Convert from domain entity to data model
  factory ChildAccountModel.fromEntity(ChildAccount entity) {
    return ChildAccountModel(
      name: entity.name,
      email: entity.email,
      currency: entity.currency,
      isPaymentDelegatedToParent: entity.isPaymentDelegatedToParent,
      parentAccountId: entity.parentAccountId,
    );
  }

  // Convert from data model to domain entity
  ChildAccount toEntity() {
    return ChildAccount(
      name: name,
      email: email,
      currency: currency,
      isPaymentDelegatedToParent: isPaymentDelegatedToParent,
      parentAccountId: parentAccountId,
    );
  }
}
