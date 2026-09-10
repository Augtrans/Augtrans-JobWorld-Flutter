import '../../core/networking/api_client.dart';
import '../model/interview/BotInterviewConfigModel.dart';
import '../model/interview/InterviewSessionModel.dart';
import 'endpoints/api_endpoints.dart';

class InterviewRepository {
  final ApiClient _client;

  InterviewRepository(this._client);

  Future<List<BotInterviewConfigModel>> getBotInterviewConfigs() async {
    try {
      return await _client.request<List<BotInterviewConfigModel>>(
        ApiConstants.botInterviewConfigsEndpoint,
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic>) {
            if (data['results'] is List) {
              list = data['results'];
            } else if (data['data'] is List) {
              list = data['data'];
            }
          }
          return list.map((e) => BotInterviewConfigModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<InterviewSessionModel> startInterviewSession(int configId) async {
    try {
      return await _client.request<InterviewSessionModel>(
        ApiConstants.startInterviewSessionEndpoint,
        method: 'POST',
        data: {'config_id': configId},
        parser: (data) => InterviewSessionModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }
}
