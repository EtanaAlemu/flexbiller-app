import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bundle_timeline.dart';
import 'bundle_event_model.dart';

part 'bundle_timeline_model.g.dart';

@JsonSerializable()
class BundleTimelineModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'bundleId')
  final String bundleId;

  @JsonKey(name: 'externalKey')
  final String externalKey;

  @JsonKey(name: 'events')
  final List<BundleEventModel> events;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  const BundleTimelineModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    required this.auditLogs,
  });

  factory BundleTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$BundleTimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleTimelineModelToJson(this);

  BundleTimeline toEntity() {
    return BundleTimeline(
      accountId: accountId,
      bundleId: bundleId,
      externalKey: externalKey,
      events: events.map((e) => e.toEntity()).toList(),
      auditLogs: auditLogs,
    );
  }
}
