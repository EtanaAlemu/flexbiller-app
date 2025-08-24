import 'package:equatable/equatable.dart';

class AccountTag extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  const AccountTag({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    icon,
    createdAt,
    updatedAt,
    createdBy,
    isActive,
  ];

  AccountTag copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
  }) {
    return AccountTag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper getters
  String get displayColor => color ?? '#2196F3'; // Default blue
  String get displayIcon => icon ?? 'label'; // Default label icon
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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
}

class AccountTagAssignment extends Equatable {
  final String id;
  final String accountId;
  final String tagId;
  final String tagName;
  final String? tagColor;
  final String? tagIcon;
  final DateTime assignedAt;
  final String assignedBy;

  const AccountTagAssignment({
    required this.id,
    required this.accountId,
    required this.tagId,
    required this.tagName,
    this.tagColor,
    this.tagIcon,
    required this.assignedAt,
    required this.assignedBy,
  });

  @override
  List<Object?> get props => [
    id,
    accountId,
    tagId,
    tagName,
    tagColor,
    tagIcon,
    assignedAt,
    assignedBy,
  ];

  String get displayColor => tagColor ?? '#2196F3';
  String get displayIcon => tagIcon ?? 'label';
}
