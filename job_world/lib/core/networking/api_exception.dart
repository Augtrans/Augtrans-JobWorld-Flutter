import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.data,
  });

  factory ApiException.badRequest({
    required String message,
    dynamic data,
  }) => ApiException(message: message, code: 400, data: data);

  factory ApiException.unknown({
    required String message,
    int? code,
    dynamic data,
  }) => ApiException(message: message, code: code, data: data);

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: 'Connection timeout', code: -1);
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Receive timeout', code: -2);
      case DioExceptionType.badResponse:
        return ApiException(
          message: 'Server error: ${e.response?.statusCode}',
          code: e.response?.statusCode,
          data: e.response?.data,
        );
      default:
        return ApiException(message: 'Unknown error: ${e.message}', code: -3);
    }
  }

  @override
  String toString() => 'ApiException(message: $message, code: $code)';
}