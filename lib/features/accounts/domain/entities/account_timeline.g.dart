// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountTimeline _$AccountTimelineFromJson(Map<String, dynamic> json) =>
    AccountTimeline(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AccountTimelineToJson(AccountTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'events': instance.events,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    TimelineEvent(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$TimelineEventToJson(TimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'metadata': instance.metadata,
      'icon': instance.icon,
      'color': instance.color,
    };
