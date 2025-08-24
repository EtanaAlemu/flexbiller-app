import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_timeline.dart';

part 'account_timeline_model.g.dart';

@JsonSerializable()
class AccountTimelineModel extends AccountTimeline {
  const AccountTimelineModel({
    required super.id,
    required super.accountId,
    required super.events,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AccountTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTimelineModelToJson(this);

  factory AccountTimelineModel.fromEntity(AccountTimeline entity) {
    return AccountTimelineModel(
      id: entity.id,
      accountId: entity.accountId,
      events: entity.events.map((e) => TimelineEventModel.fromEntity(e)).toList(),
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
class TimelineEventModel extends TimelineEvent {
  const TimelineEventModel({
    required super.id,
    required super.eventType,
    required super.title,
    required super.description,
    required super.timestamp,
    super.userId,
    super.userName,
    super.userEmail,
    super.metadata,
    super.icon,
    super.color,
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
