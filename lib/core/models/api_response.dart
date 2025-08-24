import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final Map<String, dynamic>? details;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
      error: json['error'] as String?,
      message: json['message'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
        'success': success,
        'data': data != null ? toJsonT(data!) : null,
        'error': error,
        'message': message,
        'details': details,
      };
}
