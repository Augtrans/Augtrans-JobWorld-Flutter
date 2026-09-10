import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_world/core/networking/api_exception.dart';
import 'package:job_world/core/networking/networking_providers.dart';
import 'package:job_world/data/model/login/LoginReqModel.dart';
import 'package:job_world/data/model/login/LoginResModel.dart';
import 'package:job_world/data/repositories/LoginRepository.dart';
import 'package:job_world/routes/AppRoute.dart';
import 'package:job_world/util/app_preferences.dart';
import 'package:job_world/util/common_methods.dart';

class LoginState {
  final bool isLoading;
  final LoginResponseModel? loginResponse;
  final String? errorMessage;

  LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    LoginResponseModel? loginResponse,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Repository Provider
final loginRepositoryProvider = Provider<LoginApiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LoginApiRepository(apiClient);
});

// ViewModel Provider
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginViewModel(repository);
});

class LoginViewModel extends StateNotifier<LoginState> {

  final LoginApiRepository _repository;

  LoginViewModel(this._repository) : super(LoginState());

  Future<void> login(
      String username,
      String password,
      BuildContext context,
      ) async {

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = LoginReqModel(username: username, password: password);
      final response = await _repository.loginUser(request);

      if (response != null && response.access.isNotEmpty) {
        final token = response.access;
        final userId = response.user.id.toString();
        final userName = response.user.username;
        final userRole = response.user.roleName;

        await AppPreferences.saveToken(
          accessToken: token,
          isTokenExternal: false,
        );

        await AppPreferences.saveUserId(userId);
        await AppPreferences.saveUserName(userName);
        await AppPreferences.saveUserRole(userRole);

        final roleUpper = userRole.trim().toUpperCase();
        if (context.mounted) {
          if (roleUpper == "TL" || roleUpper == "TEAM LEAD" || roleUpper == "TEAMLEAD") {
            context.go(AppRoutes.tlMainNavigation);
          } else {
            context.go(AppRoutes.home);
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        loginResponse: response,
      );

    } on ApiException catch (e) {
      String errorMessage = 'Something went wrong';

      // Check if API returned a specific error message in the response body
      if (e.data != null && e.data is Map) {
        if (e.data.containsKey('error')) {
          errorMessage = e.data['error'].toString();
        } else if (e.data.containsKey('message')) {
          errorMessage = e.data['message'].toString();
        }
      } else if (e.code == 400 || e.code == 401) {
        errorMessage = 'Invalid username or password';
      } else if (e.message.isNotEmpty) {
        errorMessage = e.message;
      }

      CommonMethods.showSnackBar(context, errorMessage);

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );

    } catch (e) {
      const errorMessage = 'Something went wrong. Please try again.';
      CommonMethods.showSnackBar(context, errorMessage);

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }
}