import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final RoleModel role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role.name,
      createdAt: DateTime.now(), // API doesn't provide this
      updatedAt: DateTime.now(), // API doesn't provide this
    );
  }
}

@JsonSerializable()
class RoleModel {
  final String id;
  final String name;

  RoleModel({
    required this.id,
    required this.name,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => _$RoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
