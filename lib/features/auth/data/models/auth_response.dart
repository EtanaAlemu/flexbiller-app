import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  AuthResponse({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String username;
  final String roleId;
  final String tenantId;
  final String role;
  final Map<String, dynamic> metadata;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.roleId,
    required this.tenantId,
    required this.role,
    required this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: '$firstName $lastName',
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phone: phone,
      tenantId: tenantId,
      roleId: roleId,
      firstName: firstName,
      lastName: lastName,
      company: metadata['company'] as String?,
      department: metadata['department'] as String?,
      location: metadata['location'] as String?,
      position: metadata['position'] as String?,
    );
  }

  // Factory method to create User from JWT token data
  factory UserModel.fromJwtData(Map<String, dynamic> jwtData) {
    final userMetadata = jwtData['user_metadata'] as Map<String, dynamic>? ?? {};
    final appMetadata = jwtData['app_metadata'] as Map<String, dynamic>? ?? {};
    final metadata = userMetadata['metadata'] as Map<String, dynamic>? ?? {};
    
    return UserModel(
      id: jwtData['sub'] as String? ?? '',
      email: jwtData['email'] as String? ?? '',
      phone: jwtData['phone'] as String? ?? '',
      firstName: userMetadata['firstName'] as String? ?? '',
      lastName: userMetadata['lastName'] as String? ?? '',
      username: userMetadata['username'] as String? ?? '',
      roleId: userMetadata['role_id'] as String? ?? appMetadata['role_id'] as String? ?? '',
      tenantId: userMetadata['tenant_id'] as String? ?? '',
      role: appMetadata['role'] as String? ?? jwtData['role'] as String? ?? '',
      metadata: metadata,
    );
  }
}
