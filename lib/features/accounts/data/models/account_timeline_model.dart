import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_timeline.dart';

part 'account_timeline_model.g.dart';

@JsonSerializable()
class AccountTimelineModel {
  final String id;
  final String accountId;
  final List<TimelineEventModel> events;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountTimelineModel({
    required this.id,
    required this.accountId,
    required this.events,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTimelineModelToJson(this);

  factory AccountTimelineModel.fromEntity(AccountTimeline entity) {
    return AccountTimelineModel(
      id: entity.id,
      accountId: entity.accountId,
      events: entity.events
          .map((e) => TimelineEventModel.fromEntity(e))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AccountTimeline toEntity() {
    return AccountTimeline(
      id: id,
      accountId: accountId,
      events: events.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class TimelineEventModel {
  final String id;
  final String eventType;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? metadata;
  final String? icon;
  final String? color;

  const TimelineEventModel({
    required this.id,
    required this.eventType,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
    this.userEmail,
    this.metadata,
    this.icon,
    this.color,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineEventModelToJson(this);

  factory TimelineEventModel.fromEntity(TimelineEvent entity) {
    return TimelineEventModel(
      id: entity.id,
      eventType: entity.eventType,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      metadata: entity.metadata,
      icon: entity.icon,
      color: entity.color,
    );
  }

  TimelineEvent toEntity() {
    return TimelineEvent(
      id: id,
      eventType: eventType,
      title: title,
      description: description,
      timestamp: timestamp,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      metadata: metadata,
      icon: icon,
      color: color,
    );
  }
}
