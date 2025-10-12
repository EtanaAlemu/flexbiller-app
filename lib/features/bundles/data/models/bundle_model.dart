import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bundle.dart';
import 'bundle_subscription_model.dart';
import 'bundle_timeline_model.dart';

part 'bundle_model.g.dart';

@JsonSerializable()
class BundleModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'bundleId')
  final String bundleId;

  @JsonKey(name: 'externalKey')
  final String externalKey;

  @JsonKey(name: 'subscriptions')
  final List<BundleSubscriptionModel> subscriptions;

  @JsonKey(name: 'timeline')
  final BundleTimelineModel timeline;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const BundleModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    this.auditLogs,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) =>
      _$BundleModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleModelToJson(this);

  Bundle toEntity() {
    return Bundle(
      accountId: accountId,
      bundleId: bundleId,
      externalKey: externalKey,
      subscriptions: subscriptions.map((s) => s.toEntity()).toList(),
      timeline: timeline.toEntity(),
      auditLogs: auditLogs,
    );
  }
}
