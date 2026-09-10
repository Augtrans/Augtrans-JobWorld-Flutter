import '../../core/networking/api_client.dart';
import '../model/practice/PracticeCategoryModel.dart';
import '../model/practice/PracticeSubcategoryModel.dart';
import '../model/practice/PracticeQuestionModel.dart';
import 'endpoints/api_endpoints.dart';

class PracticeRepository {

  final ApiClient _client;

  PracticeRepository(this._client);

  Future<List<PracticeCategoryModel>> getCategories() async {
    try {
      return await _client.request<List<PracticeCategoryModel>>(
        ApiConstants.practiceCategoriesEndpoint,
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is Map<String, dynamic>) {
            final results = data['results'];
            if (results is Map<String, dynamic> && results['data'] is List) {
              list = results['data'];
            } else if (results is List) {
              list = results;
            } else if (data['data'] is List) {
              list = data['data'];
            }
          } else if (data is List) {
            list = data;
          }
          return list.map((e) => PracticeCategoryModel.fromJson(e)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PracticeSubcategoryModel>> getSubcategories(int categoryId) async {
    try {
      return await _client.request<List<PracticeSubcategoryModel>>(
        '${ApiConstants.practiceSubcategoriesEndpoint}$categoryId/',
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic>) {
            final results = data['results'];
            if (results is List) {
              list = results;
            } else if (results is Map<String, dynamic> && results['data'] is List) {
              list = results['data'];
            } else if (data['data'] is List) {
              list = data['data'];
            }
          }
          return list.map((e) => PracticeSubcategoryModel.fromJson(e)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PracticeQuestionModel>> getQuestions(int subCategoryId) async {
    try {
      return await _client.request<List<PracticeQuestionModel>>(
        '${ApiConstants.practiceSubcategoriesEndpoint}$subCategoryId${ApiConstants.practiceQuestionsSuffix}',
        method: 'GET',
        parser: (data) {
          List list = [];
          if (data is Map<String, dynamic>) {
            final results = data['results'];
            if (results is Map<String, dynamic> && results['data'] is List) {
              list = results['data'];
            } else if (results is List) {
              list = results;
            } else if (data['data'] is List) {
              list = data['data'];
            }
          } else if (data is List) {
            list = data;
          }
          return list.map((e) => PracticeQuestionModel.fromJson(e)).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}