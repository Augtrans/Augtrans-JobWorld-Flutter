import '../../core/networking/api_client.dart';
import '../model/exam/McqExamModel.dart';
import '../model/exam/McqExamQuestionModel.dart';
import '../model/exam/ExamAttemptModel.dart';
import '../model/exam/ExamAnswerModel.dart';
import '../model/exam/ExamResultModel.dart';
import '../model/exam/ExamTitleModel.dart';
import 'endpoints/api_endpoints.dart';

class ExamRepository {
  final ApiClient _client;

  ExamRepository(this._client);

  Future<List<McqExamModel>> getPracticeExams() async {
    try {
      return await _client.request<List<McqExamModel>>(
        ApiConstants.examExamsEndpoint,
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
          return list.map((e) => McqExamModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<McqExamQuestionModel>> getExamQuestions(int examId) async {
    try {
      return await _client.request<List<McqExamQuestionModel>>(
        '${ApiConstants.examExamsQuestionsEndpoint}?exam_id=$examId',
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
          return list.map((e) => McqExamQuestionModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExamTitleModel>> getExamTitles() async {
    try {
      return await _client.request<List<ExamTitleModel>>(
        ApiConstants.examTitlesEndpoint,
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
          return list.map((e) => ExamTitleModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ExamAttemptModel> startExamAttempt(int examId, {int? packId}) async {
    try {
      final Map<String, dynamic> body = {'exam': examId};
      if (packId != null && packId > 0) {
        body['pack_id'] = packId;
      }
      return await _client.request<ExamAttemptModel>(
        ApiConstants.examStartExamEndpoint,
        method: 'POST',
        data: body,
        parser: (data) => ExamAttemptModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bulkSubmitAnswers(int attemptId, List<ExamAnswerModel> answers) async {
    try {
      return await _client.request(
        ApiConstants.examAnswersBulkSubmitEndpoint,
        method: 'POST',
        data: {
          'attempt_id': attemptId,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
        parser: (data) => data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ExamResultModel> completeExam(int attemptId) async {
    try {
      return await _client.request<ExamResultModel>(
        '${ApiConstants.examStartExamEndpoint}$attemptId/',
        method: 'PATCH',
        data: {
          'is_completed': true,
          'pack_id': null,
          'contest_id': null,
        },
        parser: (data) => ExamResultModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<McqExamModel> createSelfAssessmentExam({
    required int titleId,
    required String difficulty,
    required String description,
    required int totalDurationMinutes,
    required int passPercentage,
    required int noOfQuestions,
    List<int>? requiredSkills,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'title': titleId,
        'job': null,
        'description': description,
        'difficulty': difficulty,
        'is_self_assessment': true,
        'total_duration_minutes': totalDurationMinutes,
        'pass_percentage': passPercentage,
        'no_of_questions': noOfQuestions,
      };

      if (requiredSkills != null) {
        payload['required_skills'] = requiredSkills;
      }

      return await _client.request<McqExamModel>(
        ApiConstants.examExamsEndpoint,
        method: 'POST',
        data: payload,
        parser: (data) => McqExamModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }
}
