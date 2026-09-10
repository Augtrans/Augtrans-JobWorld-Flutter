import 'package:job_world/data/model/login/LoginReqModel.dart';
import 'package:job_world/data/model/login/LoginResModel.dart';
import '../../core/networking/api_client.dart';
import 'endpoints/api_endpoints.dart';

class LoginApiRepository {

  final ApiClient _client;

  LoginApiRepository(this._client);

  Future<T> callApi<T>({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) parser,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _client.request(
        endpoint,
        method: method,
        data: data,
        queryParameters: queryParameters,
        parser: parser,
        headers: headers,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponseModel?> loginUser(LoginReqModel request) async {
    return callApi(
      endpoint: ApiConstants.loginEndpoint,
      method: 'POST',
      data: request.toJson(),
      parser: (data) => LoginResponseModel.fromJson(data),
    );
  }

  static bool _isSuccess(int? statusCode) {
    return statusCode == 200 || statusCode == 201;
  }

  static String _errorMessage(int? code, String body) {
    return "Request failed ($code)";
  }

}