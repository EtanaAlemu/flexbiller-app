import 'package:json_annotation/json_annotation.dart';
import 'account_subscription_model.dart';
import 'account_bundle_timeline_model.dart';

part 'account_bundle_model.g.dart';

@JsonSerializable()
class AccountBundleModel {
  @JsonKey(name: 'accountId')
  final String accountId;
  
  @JsonKey(name: 'bundleId')
  final String bundleId;
  
  @JsonKey(name: 'externalKey')
  final String externalKey;
  
  @JsonKey(name: 'subscriptions')
  final List<AccountSubscriptionModel> subscriptions;
  
  @JsonKey(name: 'timeline')
  final AccountBundleTimelineModel timeline;
  
  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const AccountBundleModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    this.auditLogs,
  });

  factory AccountBundleModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBundleModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBundleModelToJson(this);
}
