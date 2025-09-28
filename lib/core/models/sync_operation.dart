import 'package:equatable/equatable.dart';

/// Represents a sync operation that needs to be performed
class SyncOperation extends Equatable {
  final String type;
  final String id;
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const SyncOperation({
    required this.type,
    required this.id,
    required this.action,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  @override
  List<Object?> get props => [type, id, action, data, timestamp, retryCount];

  SyncOperation copyWith({
    String? type,
    String? id,
    String? action,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncOperation(
      type: type ?? this.type,
      id: id ?? this.id,
      action: action ?? this.action,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      type: json['type'] as String,
      id: json['id'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'action': action,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }
}
