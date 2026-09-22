import '../../core/networking/api_client.dart';
import '../model/jobpost/TlAttachedCvModel.dart';
import '../model/jobpost/TlJobPostModel.dart';
import '../model/profile/EducationMasterModel.dart';
import '../../ui/tl/jobs/tl_models.dart';
import 'endpoints/api_endpoints.dart';

class TlJobRepository {
  final ApiClient _client;

  TlJobRepository(this._client);

  Future<List<TlJobPostModel>> getPostedJobs() async {
    return await _client.request<List<TlJobPostModel>>(
      ApiConstants.tlPostedJobsEndpoint,
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
        return list.map((e) => TlJobPostModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
  Future<TlJobPostModel> getJobById(int id) async {
    return await _client.request<TlJobPostModel>(
      '${ApiConstants.tlPostedJobsEndpoint}$id/',
      method: 'GET',
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<TlJobPostModel> createJob(Map<String, dynamic> body) async {
    return await _client.request<TlJobPostModel>(
      ApiConstants.tlPostedJobsEndpoint,
      method: 'POST',
      data: body,
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT — replaces every field on the job post. Use when the whole edit
  /// form is submitted.
  Future<TlJobPostModel> updateJob(int id, Map<String, dynamic> body) async {
    return await _client.request<TlJobPostModel>(
      '${ApiConstants.tlPostedJobsEndpoint}$id/',
      method: 'PUT',
      data: body,
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PATCH — updates only the fields present in [body], leaving the rest
  /// untouched server-side.
  Future<TlJobPostModel> patchJob(int id, Map<String, dynamic> body) async {
    return await _client.request<TlJobPostModel>(
      '${ApiConstants.tlPostedJobsEndpoint}$id/',
      method: 'PATCH',
      data: body,
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PATCH .../post-jobs/{id}/update-status/ — the dedicated lifecycle
  /// transition endpoint. [statusCode] is "1" (Open), "2" (Closed) or
  /// "3" (On Hold); the server validates TAT/assigned-recruiter for Open
  /// and rejects holding an already-closed job.
  Future<TlJobPostModel> updateJobStatus(int id, String statusCode) async {
    return await _client.request<TlJobPostModel>(
      '${ApiConstants.tlPostedJobsEndpoint}$id/update-status/',
      method: 'PATCH',
      data: {"status": statusCode},
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /jobpost/attached-cvs/ — every CV attached across the TL's jobs.
  /// No server-side job filter is documented, so callers filter the result
  /// by `post_job` client-side.
  Future<List<TlAttachedCvModel>> getAttachedCvs() async {
    return await _client.request<List<TlAttachedCvModel>>(
      ApiConstants.attachedCvsEndpoint,
      method: 'GET',
      parser: (data) {
        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data['results'] is List) {
          list = data['results'];
        }
        return list.map((e) => TlAttachedCvModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// GET .../post-jobs/{id}/rank-cvs/ — AI-ranks every CV attached to this
  /// job post; called from the "Rank CV with AI" button on the job detail
  /// screen.
  Future<TlRankCvsResult> rankCvs(int jobId) async {
    return await _client.request<TlRankCvsResult>(
      '${ApiConstants.tlPostedJobsEndpoint}$jobId/${ApiConstants.rankCvsSuffix}',
      method: 'GET',
      parser: (data) => TlRankCvsResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PATCH .../post-jobs/{id}/update-remark/ — sets the job's remark,
  /// from the "Add" remark dialog on a job card.
  Future<TlJobPostModel> updateJobRemark(int id, String remark) async {
    return await _client.request<TlJobPostModel>(
      '${ApiConstants.tlPostedJobsEndpoint}$id/update-remark/',
      method: 'PATCH',
      data: {"remark": remark},
      parser: (data) => TlJobPostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /jobpost/jobs/{id}/approval-history/ — the job post's approval
  /// workflow log, shown from the Timeline/history icon on a job card.
  Future<TlJobApprovalHistoryModel> getJobApprovalHistory(int jobId) async {
    return await _client.request<TlJobApprovalHistoryModel>(
      '${ApiConstants.jobApprovalHistoryBase}$jobId/approval-history/',
      method: 'GET',
      parser: (data) => TlJobApprovalHistoryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /user/users/?context=jobpost_assign — users eligible for job
  /// assignment. Filtered client-side to `role_name == "RECRUITER"` for
  /// the "Assigned Recruiter" dropdown.
  Future<List<TlJobAssignUserModel>> getAssignableRecruiters() async {
    return await _client.request<List<TlJobAssignUserModel>>(
      ApiConstants.jobPostAssignUsersEndpoint,
      method: 'GET',
      queryParameters: const {'context': 'jobpost_assign'},
      parser: (data) {
        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data['results'] is List) {
          list = data['results'];
        }
        return list
            .map((e) => TlJobAssignUserModel.fromJson(e as Map<String, dynamic>))
            .where((u) => u.roleName == 'RECRUITER')
            .toList();
      },
    );
  }

  /// Calls the AI Refine endpoint for the JobPost module and returns the
  /// raw `refined_data` map (already resolved ids + `_ai_suggestions`).
  Future<Map<String, dynamic>> refineJobPostWithAi(String jobTitle) async {
    return await _client.request<Map<String, dynamic>>(
      ApiConstants.aiRefineEndpoint,
      method: 'POST',
      data: {
        "module": "JobPost",
        "data": {"job_title": jobTitle},
      },
      parser: (data) => (data as Map<String, dynamic>)['refined_data'] as Map<String, dynamic>,
    );
  }

  Future<List<EducationMasterModel>> getContinents() async {
    return await _client.request<List<EducationMasterModel>>(
      ApiConstants.continentsEndpoint,
      method: 'GET',
      parser: (data) => _parseMasterList(data),
    );
  }

  Future<List<EducationMasterModel>> getCountries(int continentId) async {
    return await _client.request<List<EducationMasterModel>>(
      ApiConstants.countriesEndpoint,
      method: 'GET',
      queryParameters: {'continent': continentId},
      parser: (data) => _parseMasterList(data),
    );
  }

  Future<List<EducationMasterModel>> getLocations(int countryId, {String? search}) async {
    final Map<String, dynamic> query = {'country': countryId};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    return await _client.request<List<EducationMasterModel>>(
      ApiConstants.locationsEndpoint,
      method: 'GET',
      queryParameters: query,
      parser: (data) => _parseMasterList(data, nameKey: 'city_name'),
    );
  }

  Future<List<EducationMasterModel>> getWorkModes() async {
    return await _client.request<List<EducationMasterModel>>(
      ApiConstants.workModesEndpoint,
      method: 'GET',
      parser: (data) => _parseMasterList(data),
    );
  }

  List<EducationMasterModel> _parseMasterList(dynamic data, {String nameKey = 'name'}) {
    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic> && data['results'] is List) {
      list = data['results'];
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      list = data['data'];
    }
    return list
        .map((e) => EducationMasterModel(id: e['id'] ?? 0, name: e[nameKey] ?? e['name'] ?? ''))
        .toList();
  }
}