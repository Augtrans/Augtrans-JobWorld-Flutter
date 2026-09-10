import '../../core/networking/api_client.dart';
import '../model/challenge_pack/ChallengePackTypeModel.dart';
import '../model/challenge_pack/PackSubdomainModel.dart';
import '../model/challenge_pack/PackSubcategoryModel.dart';
import '../model/exam/McqExamModel.dart';
import '../model/practice/PracticeQuestionModel.dart';
import 'endpoints/api_endpoints.dart';

class ChallengePackRepository {
  final ApiClient _client;

  ChallengePackRepository(this._client);

  Future<List<ChallengePackTypeModel>> getPackTypes() async {
    try {
      return await _client.request<List<ChallengePackTypeModel>>(
        ApiConstants.challengePacksEndpoint,
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
          return list.map((e) => ChallengePackTypeModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PackSubdomainModel>> getMcqSubdomains(int domainId) async {
    try {
      return await _client.request<List<PackSubdomainModel>>(
        '${ApiConstants.challengePackMcqEndpoint}$domainId/',
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic> && data['data'] is List) {
            list = data['data'];
          }
          return list.map((e) => PackSubdomainModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PackSubcategoryModel>> getCodingSubcategories(int categoryId) async {
    try {
      return await _client.request<List<PackSubcategoryModel>>(
        '${ApiConstants.challengePackCodingEndpoint}$categoryId/',
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic> && data['data'] is List) {
            list = data['data'];
          }
          return list.map((e) => PackSubcategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<McqExamModel>> getSubdomainExams(int subdomainId) async {
    try {
      return await _client.request<List<McqExamModel>>(
        '${ApiConstants.challengePackSubdomainExamsEndpoint}$subdomainId/',
        method: 'GET',
        parser: (data) {
          List list = [];
          int? packId;
          if (data is Map<String, dynamic> && data['exams'] is List) {
            list = data['exams'];
            packId = data['pack_id'] is int ? data['pack_id'] as int : int.tryParse(data['pack_id'].toString());
          } else if (data is List) {
            list = data;
          }
          return list
              .map((e) => McqExamModel.fromJson(e as Map<String, dynamic>).copyWith(packId: packId))
              .toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PracticeQuestionModel>> getSubdomainCodingQuestions(int subcategoryId) async {
    try {
      return await _client.request<List<PracticeQuestionModel>>(
        '${ApiConstants.challengePackSubdomainCodingEndpoint}$subcategoryId/',
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is Map<String, dynamic> && data['questions'] is List) {
            list = data['questions'];
          } else if (data is List) {
            list = data;
          }
          return list.map((e) => PracticeQuestionModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}