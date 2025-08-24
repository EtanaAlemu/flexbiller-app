import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_email.dart';

part 'account_email_model.g.dart';

@JsonSerializable()
class AccountEmailModel {
  @JsonKey(name: 'accountId')
  final String accountId;
  final String email;

  const AccountEmailModel({
    required this.accountId,
    required this.email,
  });

  factory AccountEmailModel.fromJson(Map<String, dynamic> json) =>
      _$AccountEmailModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountEmailModelToJson(this);

  factory AccountEmailModel.fromEntity(AccountEmail entity) {
    return AccountEmailModel(
      accountId: entity.accountId,
      email: entity.email,
    );
  }

  AccountEmail toEntity() {
    return AccountEmail(
      accountId: accountId,
      email: email,
    );
  }
}
