import 'package:json_annotation/json_annotation.dart';

part 'jwt_token.g.dart';

@JsonSerializable()
class JwtToken {
  final String? iss;
  final String? sub;
  final String? aud;
  final int? exp;
  final int? iat;
  final String? email;
  final String? phone;
  @JsonKey(name: 'app_metadata')
  final AppMetadata? appMetadata;
  @JsonKey(name: 'user_metadata')
  final UserMetadata? userMetadata;
  final String? role;
  final String? aal;
  final List<Amr>? amr;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  @JsonKey(name: 'is_anonymous')
  final bool? isAnonymous;

  JwtToken({
    this.iss,
    this.sub,
    this.aud,
    this.exp,
    this.iat,
    this.email,
    this.phone,
    this.appMetadata,
    this.userMetadata,
    this.role,
    this.aal,
    this.amr,
    this.sessionId,
    this.isAnonymous,
  });

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      _$JwtTokenFromJson(json);
  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);

  // Helper methods
  bool get isExpired {
    if (exp == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp! < now;
  }

  DateTime? get expirationDate {
    if (exp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp! * 1000);
  }

  DateTime? get issuedAtDate {
    if (iat == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(iat! * 1000);
  }

  String get fullName {
    if (userMetadata?.firstName == null || userMetadata?.lastName == null)
      return '';
    return '${userMetadata!.firstName} ${userMetadata!.lastName}';
  }

  String get company => userMetadata?.metadata?.company ?? '';
  String get department => userMetadata?.metadata?.department ?? '';
  String get location => userMetadata?.metadata?.location ?? '';
  String get position => userMetadata?.metadata?.position ?? '';
  String get tenantId => userMetadata?.tenantId ?? '';
  String get roleId => userMetadata?.roleId ?? '';
  String get apiKey => userMetadata?.apiKey ?? '';
  String get apiSecret => userMetadata?.apiSecret ?? '';
  bool get isEmailVerified => userMetadata?.emailVerified ?? false;
}

@JsonSerializable()
class AppMetadata {
  final String? provider;
  final List<String>? providers;
  final String? role;
  @JsonKey(name: 'role_id')
  final String? roleId;

  AppMetadata({this.provider, this.providers, this.role, this.roleId});

  factory AppMetadata.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$AppMetadataToJson(this);
}

@JsonSerializable()
class UserMetadata {
  final String? apiKey;
  final String? apiSecret;
  @JsonKey(name: 'emailVerified')
  final bool? emailVerified;
  @JsonKey(name: 'firstName')
  final String? firstName;
  @JsonKey(name: 'lastName')
  final String? lastName;
  final UserMetadataDetails? metadata;
  @JsonKey(name: 'roleId')
  final String? roleId;
  @JsonKey(name: 'tenantId')
  final String? tenantId;

  UserMetadata({
    this.apiKey,
    this.apiSecret,
    this.emailVerified,
    this.firstName,
    this.lastName,
    this.metadata,
    this.roleId,
    this.tenantId,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataToJson(this);
}

@JsonSerializable()
class UserMetadataDetails {
  final String? company;
  final String? department;
  final String? location;
  final String? position;

  UserMetadataDetails({
    this.company,
    this.department,
    this.location,
    this.position,
  });

  factory UserMetadataDetails.fromJson(Map<String, dynamic> json) =>
      _$UserMetadataDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UserMetadataDetailsToJson(this);
}

@JsonSerializable()
class Amr {
  final String? method;
  final int? timestamp;

  Amr({this.method, this.timestamp});

  factory Amr.fromJson(Map<String, dynamic> json) => _$AmrFromJson(json);
  Map<String, dynamic> toJson() => _$AmrToJson(this);

  DateTime? get timestampDate {
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  }
}
