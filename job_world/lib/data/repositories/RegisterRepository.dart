import '../../core/networking/api_client.dart';
import '../model/register/DepartmentModel.dart';
import '../model/register/OrganizationModel.dart';
import '../model/register/OrgRegisterReqModel.dart';
import '../model/register/RegisterReqModel.dart';
import '../model/register/RegisterResModel.dart';
import '../model/register/RoleModel.dart';
import '../model/register/UserRegisterReqModel.dart';
import 'endpoints/api_endpoints.dart';

class RegisterApiRepository {

  final ApiClient _client;

  RegisterApiRepository(this._client);

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

  Future<RegisterResModel?> registerOrg(RegisterReqModel request) async {
    return callApi(
      endpoint: ApiConstants.registerOrgEndpoint,
      method: 'POST',
      data: request.toJson(),
      parser: (data) => RegisterResModel.fromJson(data),
    );
  }

  Future<dynamic> createOrganization(OrgRegisterReqModel request) async {
    return callApi(
      endpoint: ApiConstants.registerOrgEndpoint,
      method: 'POST',
      data: request.toJson(),
      parser: (data) => data,
    );
  }

  Future<dynamic> registerUser(UserRegisterReqModel request) async {
    return callApi(
      endpoint: ApiConstants.userRegisterEndpoint,
      method: 'POST',
      data: request.toJson(),
      parser: (data) => data,
    );
  }

  Future<dynamic> verifyOtp(String email, String otp) async {
    return callApi(
      endpoint: ApiConstants.userVerifyOTPEndpoint,
      method: 'POST',
      data: {
        'email': email,
        'otp': otp,
      },
      parser: (data) => data,
    );
  }

  Future<List<RoleModel>> getRoles() async {
    return callApi(
      endpoint: ApiConstants.allOrgRoleDropdownEndpoint,
      method: 'GET',
      parser: (data) {
        if (data is List) {
          return data.map((item) => RoleModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    return callApi(
      endpoint: ApiConstants.allOrgDropdownEndpoint,
      method: 'GET',
      parser: (data) {
        if (data is List) {
          return data.map((item) => OrganizationModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  Future<List<DepartmentModel>> getDepartments(int organizationId) async {
    return callApi(
      endpoint: ApiConstants.allDeptDropdownEndpoint,
      method: 'GET',
      queryParameters: {'organization': organizationId},
      parser: (data) {
        if (data is List) {
          return data.map((item) => DepartmentModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  static bool _isSuccess(int? statusCode) {
    return statusCode == 200 || statusCode == 201;
  }

  static String _errorMessage(int? code, String body) {
    return "Request failed ($code)";
  }
}