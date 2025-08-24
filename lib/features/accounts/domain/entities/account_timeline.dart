import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_timeline.g.dart';

@JsonSerializable()
class AccountTimeline extends Equatable {
  final String id;
  final String accountId;
  final List<TimelineEvent> events;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountTimeline({
    required this.id,
    required this.accountId,
    required this.events,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, accountId, events, createdAt, updatedAt];

  AccountTimeline copyWith({
    String? id,
    String? accountId,
    List<TimelineEvent>? events,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountTimeline(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class TimelineEvent extends Equatable {
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

  const TimelineEvent({
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

  @override
  List<Object?> get props => [
        id,
        eventType,
        title,
        description,
        timestamp,
        userId,
        userName,
        userEmail,
        metadata,
        icon,
        color,
      ];

  // Helper getters
  bool get isUserAction => userId != null;
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get displayIcon {
    return icon ?? _getDefaultIcon();
  }

  String get displayColor {
    return color ?? _getDefaultColor();
  }

  String _getDefaultIcon() {
    switch (eventType.toLowerCase()) {
      case 'account_created':
        return 'account_circle';
      case 'account_updated':
        return 'edit';
      case 'payment_received':
        return 'payment';
      case 'invoice_created':
        return 'receipt';
      case 'invoice_paid':
        return 'check_circle';
      case 'balance_changed':
        return 'account_balance_wallet';
      case 'contact_updated':
        return 'contact_phone';
      case 'settings_changed':
        return 'settings';
      default:
        return 'info';
    }
  }

  String _getDefaultColor() {
    switch (eventType.toLowerCase()) {
      case 'account_created':
        return '#4CAF50'; // Green
      case 'account_updated':
        return '#2196F3'; // Blue
      case 'payment_received':
        return '#4CAF50'; // Green
      case 'invoice_created':
        return '#FF9800'; // Orange
      case 'invoice_paid':
        return '#4CAF50'; // Green
      case 'balance_changed':
        return '#9C27B0'; // Purple
      case 'contact_updated':
        return '#2196F3'; // Blue
      case 'settings_changed':
        return '#607D8B'; // Blue Grey
      default:
        return '#757575'; // Grey
    }
  }

  TimelineEvent copyWith({
    String? id,
    String? eventType,
    String? title,
    String? description,
    DateTime? timestamp,
    String? userId,
    String? userName,
    String? userEmail,
    Map<String, dynamic>? metadata,
    String? icon,
    String? color,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      metadata: metadata ?? this.metadata,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
