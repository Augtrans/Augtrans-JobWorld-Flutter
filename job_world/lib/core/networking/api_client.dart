import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../util/constants.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'retry_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: Constants.BASE_URL,
      connectTimeout: const Duration(seconds: 50),
      receiveTimeout: const Duration(seconds: 50),
    ),
  ) {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
      RetryInterceptor(dio: _dio, retries: 3),
    ]);
  }

  Future<T> request<T>(
      String path, {
        String method = 'GET',
        dynamic data,
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic) parser,
        Map<String, dynamic>? headers,
      }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      debugPrint("DioException Type: ${e.type}");
      debugPrint("DioException Message: ${e.message}");
      debugPrint("Request URL: ${e.requestOptions.uri}");

      if (e.response != null) {
        debugPrint("Status Code: ${e.response?.statusCode}");
        debugPrint("Response Body: ${e.response?.data}");
      } else {
        debugPrint("No response from server (connection issue)");
      }
      throw ApiException.fromDioException(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic) parser) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return parser(response.data);
      case 400:
        throw ApiException.badRequest(
          message: 'Bad request: ${response.data['message'] ?? 'Invalid parameters'}',
          data: response.data,
        );
      default:
        throw ApiException.unknown(
          message: 'Unexpected error: ${response.statusCode}',
          code: response.statusCode,
          data: response.data,
      );
    }
  }
}