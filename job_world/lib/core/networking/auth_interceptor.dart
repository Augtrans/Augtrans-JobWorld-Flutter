import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../util/app_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AppPreferences.getAccessToken();
    debugPrint("AuthInterceptor: Token retrieved for ${options.path}: $token");
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint("AuthInterceptor: Added Authorization header");
    } else {
      debugPrint("AuthInterceptor: No token found");
    }
    
    return handler.next(options);
  }
}
