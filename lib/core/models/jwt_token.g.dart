// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtToken _$JwtTokenFromJson(Map<String, dynamic> json) => JwtToken(
  iss: json['iss'] as String?,
  sub: json['sub'] as String?,
  aud: json['aud'] as String?,
  exp: (json['exp'] as num?)?.toInt(),
  iat: (json['iat'] as num?)?.toInt(),
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  appMetadata: json['app_metadata'] == null
      ? null
      : AppMetadata.fromJson(json['app_metadata'] as Map<String, dynamic>),
  userMetadata: json['user_metadata'] == null
      ? null
      : UserMetadata.fromJson(json['user_metadata'] as Map<String, dynamic>),
  role: json['role'] as String?,
  aal: json['aal'] as String?,
  amr: (json['amr'] as List<dynamic>?)
      ?.map((e) => Amr.fromJson(e as Map<String, dynamic>))
      .toList(),
  sessionId: json['session_id'] as String?,
  isAnonymous: json['is_anonymous'] as bool?,
);

Map<String, dynamic> _$JwtTokenToJson(JwtToken instance) => <String, dynamic>{
  'iss': instance.iss,
  'sub': instance.sub,
  'aud': instance.aud,
  'exp': instance.exp,
  'iat': instance.iat,
  'email': instance.email,
  'phone': instance.phone,
  'app_metadata': instance.appMetadata,
  'user_metadata': instance.userMetadata,
  'role': instance.role,
  'aal': instance.aal,
  'amr': instance.amr,
  'session_id': instance.sessionId,
  'is_anonymous': instance.isAnonymous,
};

AppMetadata _$AppMetadataFromJson(Map<String, dynamic> json) => AppMetadata(
  provider: json['provider'] as String?,
  providers: (json['providers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  role: json['role'] as String?,
  roleId: json['role_id'] as String?,
);

Map<String, dynamic> _$AppMetadataToJson(AppMetadata instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'providers': instance.providers,
      'role': instance.role,
      'role_id': instance.roleId,
    };

UserMetadata _$UserMetadataFromJson(Map<String, dynamic> json) => UserMetadata(
  apiKey: json['apiKey'] as String?,
  apiSecret: json['apiSecret'] as String?,
  emailVerified: json['emailVerified'] as bool?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  metadata: json['metadata'] == null
      ? null
      : UserMetadataDetails.fromJson(json['metadata'] as Map<String, dynamic>),
  roleId: json['roleId'] as String?,
  tenantId: json['tenantId'] as String?,
);

Map<String, dynamic> _$UserMetadataToJson(UserMetadata instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'apiSecret': instance.apiSecret,
      'emailVerified': instance.emailVerified,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'metadata': instance.metadata,
      'roleId': instance.roleId,
      'tenantId': instance.tenantId,
    };

UserMetadataDetails _$UserMetadataDetailsFromJson(Map<String, dynamic> json) =>
    UserMetadataDetails(
      company: json['company'] as String?,
      department: json['department'] as String?,
      location: json['location'] as String?,
      position: json['position'] as String?,
    );

Map<String, dynamic> _$UserMetadataDetailsToJson(
  UserMetadataDetails instance,
) => <String, dynamic>{
  'company': instance.company,
  'department': instance.department,
  'location': instance.location,
  'position': instance.position,
};

Amr _$AmrFromJson(Map<String, dynamic> json) => Amr(
  method: json['method'] as String?,
  timestamp: (json['timestamp'] as num?)?.toInt(),
);

Map<String, dynamic> _$AmrToJson(Amr instance) => <String, dynamic>{
  'method': instance.method,
  'timestamp': instance.timestamp,
};
