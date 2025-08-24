import 'package:json_annotation/json_annotation.dart';

part 'jwt_token.g.dart';

@JsonSerializable()
class JwtToken {
  final String iss;
  final String sub;
  final String aud;
  final int exp;
  final int iat;
  final String email;
  final String phone;
  final AppMetadata appMetadata;
  final UserMetadata userMetadata;
  final String role;
  final String aal;
  final List<Amr> amr;
  final String sessionId;
  final bool isAnonymous;

  JwtToken({
    required this.iss,
    required this.sub,
    required this.aud,
    required this.exp,
    required this.iat,
    required this.email,
    required this.phone,
    required this.appMetadata,
    required this.userMetadata,
    required this.role,
    required this.aal,
    required this.amr,
    required this.sessionId,
    required this.isAnonymous,
  });

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      _$JwtTokenFromJson(json);
  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);

  // Helper methods
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp < now;
  }

  DateTime get expirationDate =>
      DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  DateTime get issuedAtDate => DateTime.fromMillisecondsSinceEpoch(iat * 1000);

  String get fullName => '${userMetadata.firstName} ${userMetadata.lastName}';
  String get company => userMetadata.metadata.company;
  String get department => userMetadata.metadata.department;
  String get location => userMetadata.metadata.location;
  String get position => userMetadata.metadata.position;
  String get tenantId => userMetadata.tenantId;
  String get roleId => userMetadata.roleId;
  String get apiKey => userMetadata.apiKey;
  String get apiSecret => userMetadata.apiSecret;
  bool get isEmailVerified => userMetadata.emailVerified;
}

@JsonSerializable()
class AppMetadata {
  final String provider;
  final List<String> providers;
  final String role;
  final String roleId;

  AppMetadata({
    required this.provider,
    required this.providers,
    required this.role,
    required this.roleId,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$AppMetadataToJson(this);
}

@JsonSerializable()
class UserMetadata {
  final String apiKey;
  final String apiSecret;
  final bool emailVerified;
  final String firstName;
  final String lastName;
  final UserMetadataDetails metadata;
  final String roleId;
  final String tenantId;

  UserMetadata({
    required this.apiKey,
    required this.apiSecret,
    required this.emailVerified,
    required this.firstName,
    required this.lastName,
    required this.metadata,
    required this.roleId,
    required this.tenantId,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataToJson(this);
}

@JsonSerializable()
class UserMetadataDetails {
  final String company;
  final String department;
  final String location;
  final String position;

  UserMetadataDetails({
    required this.company,
    required this.department,
    required this.location,
    required this.position,
  });

  factory UserMetadataDetails.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataDetailsToJson(this);
}

@JsonSerializable()
class Amr {
  final String method;
  final int timestamp;

  Amr({required this.method, required this.timestamp});

  factory Amr.fromJson(Map<String, dynamic> json) => _$AmrFromJson(json);
  Map<String, dynamic> toJson() => _$AmrToJson(this);

  DateTime get timestampDate =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
