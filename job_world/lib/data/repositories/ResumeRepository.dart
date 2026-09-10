import '../../core/networking/api_client.dart';
import '../model/profile/ResumeTemplateModel.dart';
import '../model/resume/JdFitmentModel.dart';
import 'endpoints/api_endpoints.dart';

class ResumeRepository {
  final ApiClient _apiClient;

  ResumeRepository(this._apiClient);

  Future<List<ResumeTemplateModel>> getTemplates() async {
    return _apiClient.request(
      ApiConstants.resumeTemplatesEndpoint,
      method: 'GET',
      parser: (data) {
        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          if (data['results'] is List) {
            list = data['results'];
          } else if (data['results'] is Map<String, dynamic> && data['results']['data'] is List) {
            list = data['results']['data'];
          } else if (data['data'] is List) {
            list = data['data'];
          }
        }
        return list.map((json) => ResumeTemplateModel.fromJson(json as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<JdFitmentModel> calculateJdFitment(String jdText) async {
    return _apiClient.request<JdFitmentModel>(
      ApiConstants.jdFitmentEndpoint,
      method: 'POST',
      data: {'jd_text': jdText},
      parser: (data) => JdFitmentModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
