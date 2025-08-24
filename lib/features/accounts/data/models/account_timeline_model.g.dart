// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountTimelineModel _$AccountTimelineModelFromJson(
  Map<String, dynamic> json,
) => AccountTimelineModel(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  events: (json['events'] as List<dynamic>)
      .map((e) => TimelineEventModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AccountTimelineModelToJson(
  AccountTimelineModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'events': instance.events,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

TimelineEventModel _$TimelineEventModelFromJson(Map<String, dynamic> json) =>
    TimelineEventModel(
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

Map<String, dynamic> _$TimelineEventModelToJson(TimelineEventModel instance) =>
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
