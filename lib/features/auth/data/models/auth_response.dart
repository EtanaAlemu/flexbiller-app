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

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: '$firstName $lastName',
      role: role,
      createdAt: DateTime.now(), // API doesn't provide this
      updatedAt: DateTime.now(), // API doesn't provide this
    );
  }
}
