import 'package:json_annotation/json_annotation.dart';
import 'account_subscription_event_model.dart';

part 'account_bundle_timeline_model.g.dart';

@JsonSerializable()
class AccountBundleTimelineModel {
  @JsonKey(name: 'accountId')
  final String accountId;
  
  @JsonKey(name: 'bundleId')
  final String bundleId;
  
  @JsonKey(name: 'externalKey')
  final String externalKey;
  
  @JsonKey(name: 'events')
  final List<AccountSubscriptionEventModel> events;
  
  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const AccountBundleTimelineModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    this.auditLogs,
  });

  factory AccountBundleTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBundleTimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBundleTimelineModelToJson(this);
}
