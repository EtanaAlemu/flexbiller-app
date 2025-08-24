import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel {
  final String id;
  final String name;
  final String email;
  final String currency;
  @JsonKey(name: 'timeZone')
  final String timeZone;
  final String address1;
  final String address2;
  final String company;
  final String city;
  final String state;
  final String country;
  final String phone;
  final String notes;
  @JsonKey(name: 'externalKey')
  final String externalKey;
  final double balance;
  final double cba;
  @JsonKey(name: 'auditLogs')
  final List<AuditLogModel> auditLogs;

  AccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.timeZone,
    required this.address1,
    required this.address2,
    required this.company,
    required this.city,
    required this.state,
    required this.country,
    required this.phone,
    required this.notes,
    required this.externalKey,
    required this.balance,
    required this.cba,
    required this.auditLogs,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      email: email,
      currency: currency,
      timeZone: timeZone,
      address1: address1,
      address2: address2,
      company: company,
      city: city,
      state: state,
      country: country,
      phone: phone,
      notes: notes,
      externalKey: externalKey,
      balance: balance,
      cba: cba,
      auditLogs: auditLogs.map((log) => log.toEntity()).toList(),
    );
  }

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      email: account.email,
      currency: account.currency,
      timeZone: account.timeZone,
      address1: account.address1,
      address2: account.address2,
      company: account.company,
      city: account.city,
      state: account.state,
      country: account.country,
      phone: account.phone,
      notes: account.notes,
      externalKey: account.externalKey,
      balance: account.balance,
      cba: account.cba,
      auditLogs: account.auditLogs
          .map((log) => AuditLogModel.fromEntity(log))
          .toList(),
    );
  }
}

@JsonSerializable()
class AuditLogModel {
  @JsonKey(name: 'changeType')
  final String changeType;
  @JsonKey(name: 'changeDate')
  final DateTime changeDate;
  @JsonKey(name: 'changedBy')
  final String changedBy;
  @JsonKey(name: 'reasonCode')
  final String reasonCode;
  final String comments;
  @JsonKey(name: 'objectType')
  final String objectType;
  @JsonKey(name: 'objectId')
  final String objectId;
  @JsonKey(name: 'userToken')
  final String userToken;

  AuditLogModel({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    required this.reasonCode,
    required this.comments,
    required this.objectType,
    required this.objectId,
    required this.userToken,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuditLogModelToJson(this);

  AuditLog toEntity() {
    return AuditLog(
      changeType: changeType,
      changeDate: changeDate,
      changedBy: changedBy,
      reasonCode: reasonCode,
      comments: comments,
      objectType: objectType,
      objectId: objectId,
      userToken: userToken,
    );
  }

  factory AuditLogModel.fromEntity(AuditLog auditLog) {
    return AuditLogModel(
      changeType: auditLog.changeType,
      changeDate: auditLog.changeDate,
      changedBy: auditLog.changedBy,
      reasonCode: auditLog.reasonCode,
      comments: auditLog.comments,
      objectType: auditLog.objectType,
      objectId: auditLog.objectId,
      userToken: auditLog.userToken,
    );
  }
}
