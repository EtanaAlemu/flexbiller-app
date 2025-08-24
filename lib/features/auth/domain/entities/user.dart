import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // JWT Token related fields
  final String? phone;
  final String? tenantId;
  final String? roleId;
  final String? apiKey;
  final String? apiSecret;
  final bool? emailVerified;
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? department;
  final String? location;
  final String? position;
  final String? sessionId;
  final bool? isAnonymous;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.tenantId,
    this.roleId,
    this.apiKey,
    this.apiSecret,
    this.emailVerified,
    this.firstName,
    this.lastName,
    this.company,
    this.department,
    this.location,
    this.position,
    this.sessionId,
    this.isAnonymous,
  });

  // Factory constructor to create User from JWT token data
  factory User.fromJwtData({
    required String id,
    required String email,
    required String role,
    String? phone,
    String? tenantId,
    String? roleId,
    String? apiKey,
    String? apiSecret,
    bool? emailVerified,
    String? firstName,
    String? lastName,
    String? company,
    String? department,
    String? location,
    String? position,
    String? sessionId,
    bool? isAnonymous,
  }) {
    final name = firstName != null && lastName != null 
        ? '$firstName $lastName' 
        : email.split('@').first;
    
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phone: phone,
      tenantId: tenantId,
      roleId: roleId,
      apiKey: apiKey,
      apiSecret: apiSecret,
      emailVerified: emailVerified,
      firstName: firstName,
      lastName: lastName,
      company: company,
      department: department,
      location: location,
      position: position,
      sessionId: sessionId,
      isAnonymous: isAnonymous,
    );
  }

  // Copy with method to update specific fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? tenantId,
    String? roleId,
    String? apiKey,
    String? apiSecret,
    bool? emailVerified,
    String? firstName,
    String? lastName,
    String? company,
    String? department,
    String? location,
    String? position,
    String? sessionId,
    bool? isAnonymous,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      tenantId: tenantId ?? this.tenantId,
      roleId: roleId ?? this.roleId,
      apiKey: apiKey ?? this.apiKey,
      apiSecret: apiSecret ?? this.apiSecret,
      emailVerified: emailVerified ?? this.emailVerified,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      department: department ?? this.department,
      location: location ?? this.location,
      position: position ?? this.position,
      sessionId: sessionId ?? this.sessionId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    createdAt,
    updatedAt,
    phone,
    tenantId,
    roleId,
    apiKey,
    apiSecret,
    emailVerified,
    firstName,
    lastName,
    company,
    department,
    location,
    position,
    sessionId,
    isAnonymous,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, tenantId: $tenantId, company: $company)';
  }

  // Helper methods
  bool get isTenantAdmin => role.toUpperCase() == 'TENANT_ADMIN';
  bool get isEasyBillAdmin => role.toUpperCase() == 'EASYBILL_ADMIN';
  bool get hasApiCredentials => apiKey != null && apiKey!.isNotEmpty && apiSecret != null && apiSecret!.isNotEmpty;
  String get displayName => firstName != null && lastName != null ? '$firstName $lastName' : name;
}

