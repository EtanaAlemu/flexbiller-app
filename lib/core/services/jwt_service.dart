import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/jwt_token.dart';
import '../errors/exceptions.dart';

@injectable
class JwtService {
  /// Decodes a JWT token and returns the payload as a JwtToken object
  JwtToken decodeToken(String token) {
    try {
      // Decode the JWT token
      final decodedToken = JwtDecoder.decode(token);
      
      // Debug: Log the actual JWT payload structure
      print('🔍 JWT Payload Structure:');
      decodedToken.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });

      // Convert to JwtToken object
      return JwtToken.fromJson(decodedToken);
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Decodes a JWT token and returns the raw payload as Map
  Map<String, dynamic> decodeTokenRaw(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Checks if a JWT token is expired
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Gets the expiration date of a JWT token
  DateTime getTokenExpiration(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final exp = decodedToken['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Gets the issued at date of a JWT token
  DateTime getTokenIssuedAt(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final iat = decodedToken['iat'] as int;
      return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts user email from JWT token
  String getUserEmail(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['email'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts user ID from JWT token
  String getUserId(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts user role from JWT token
  String getUserRole(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final appMetadata = decodedToken['app_metadata'] as Map<String, dynamic>?;
      return appMetadata?['role'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts tenant ID from JWT token
  String getTenantId(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      return userMetadata?['tenant_id'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts API key from JWT token
  String getApiKey(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      return userMetadata?['api_key'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Extracts API secret from JWT token
  String getApiSecret(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      return userMetadata?['api_secret'] as String? ?? '';
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Checks if user has a specific role
  bool hasRole(String token, String role) {
    try {
      final userRole = getUserRole(token);
      return userRole.toLowerCase() == role.toLowerCase();
    } catch (e) {
      return false;
    }
  }

  /// Checks if user is a tenant admin
  bool isTenantAdmin(String token) {
    return hasRole(token, 'TENANT_ADMIN');
  }

  /// Checks if user is an easy bill admin
  bool isEasyBillAdmin(String token) {
    return hasRole(token, 'EASYBILL_ADMIN');
  }

  /// Checks if user has API credentials
  bool hasApiCredentials(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final apiKey = userMetadata?['api_key'] as String? ?? '';
      final apiSecret = userMetadata?['api_secret'] as String? ?? '';
      return apiKey.isNotEmpty && apiSecret.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Checks if user can make API calls
  bool canMakeApiCalls(String token) {
    return isTenantAdmin(token) && hasApiCredentials(token);
  }

  /// Gets user's display name from JWT token
  String getUserDisplayName(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final firstName = userMetadata?['firstName'] as String? ?? '';
      final lastName = userMetadata?['lastName'] as String? ?? '';

      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName';
      } else if (firstName.isNotEmpty) {
        return firstName;
      } else if (lastName.isNotEmpty) {
        return lastName;
      } else {
        // Fallback to email username
        final email = decodedToken['email'] as String? ?? '';
        return email.split('@').first;
      }
    } catch (e) {
      return 'Unknown User';
    }
  }

  /// Gets user's company information
  String getUserCompany(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final metadata = userMetadata?['metadata'] as Map<String, dynamic>?;
      return metadata?['company'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Gets user's department
  String getUserDepartment(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final metadata = userMetadata?['metadata'] as Map<String, dynamic>?;
      return metadata?['department'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Gets user's location
  String getUserLocation(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final metadata = userMetadata?['metadata'] as Map<String, dynamic>?;
      return metadata?['location'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Gets user's position
  String getUserPosition(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userMetadata =
          decodedToken['user_metadata'] as Map<String, dynamic>?;
      final metadata = userMetadata?['metadata'] as Map<String, dynamic>?;
      return metadata?['position'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Checks if user has phone verification
  bool hasPhoneVerification(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final appMetadata = decodedToken['app_metadata'] as Map<String, dynamic>?;
      final providers = appMetadata?['providers'] as List<dynamic>? ?? [];
      return providers.contains('phone');
    } catch (e) {
      return false;
    }
  }

  /// Gets user's phone number
  String getUserPhone(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['phone'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Gets all user metadata as a Map
  Map<String, dynamic> getUserMetadata(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_metadata'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }

  /// Gets all app metadata as a Map
  Map<String, dynamic> getAppMetadata(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['app_metadata'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw AuthException('Invalid JWT token: $e');
    }
  }
}
