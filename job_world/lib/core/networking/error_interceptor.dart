import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../routes/AppRoute.dart';
import '../../routes/app_navigator.dart';
import '../../util/app_preferences.dart';
import '../../util/common_methods.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      debugPrint("ErrorInterceptor: 401 Unauthorized detected. Logging out...");
      
      // Clear all stored user data
      await AppPreferences.clear();
      
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Show a message to the user
        CommonMethods.showSnackBar(context, "Session expired. Please login again.");
        
        // Redirect to login screen
        context.go(AppRoutes.login);
      }
    }
    super.onError(err, handler);
  }
}
