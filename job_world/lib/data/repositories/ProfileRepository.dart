import 'package:dio/dio.dart';
import '../../core/networking/api_client.dart';
import '../model/profile/CertificationModel.dart';
import '../model/profile/CvModel.dart';
import '../model/profile/EducationModel.dart';
import '../model/profile/EducationMasterModel.dart';
import '../model/profile/EmploymentModel.dart';
import '../model/profile/JobPreferenceModel.dart';
import '../model/profile/ProjectModel.dart';
import '../model/profile/SkillModel.dart';
import '../model/profile/UserProfileModel.dart';
import 'endpoints/api_endpoints.dart';

class ProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  Future<UserProfileModel?> getUserProfile() async {
    try {
      final response = await _client.request(
        ApiConstants.userProfileEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List && data.isNotEmpty) {
            return UserProfileModel.fromJson(data[0]);
          }
          return null;
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel> updateProfile(int profileId, Map<String, dynamic> data) async {
    try {
      final response = await _client.request(
        "${ApiConstants.userProfileEndpoint}$profileId/",
        method: 'PATCH',
        data: data,
        parser: (data) => UserProfileModel.fromJson(data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> uploadCv(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'source_type': "UPLOADED",
        'pdf_file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });

      return await _client.request(
        ApiConstants.uploadCvEndpoint,
        method: 'POST',
        data: formData,
        parser: (data) => data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CvModel>> getUserCvs() async {
    try {
      final response = await _client.request<List<CvModel>>(
        ApiConstants.uploadCvEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => CvModel.fromJson(e)).toList();
          }
          return <CvModel>[];
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EmploymentModel>> getEmploymentList() async {
    try {
      return await _client.request<List<EmploymentModel>>(
        ApiConstants.userEmploymentEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EmploymentModel.fromJson(e)).toList();
          }
          return <EmploymentModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EmploymentModel> addEmployment(EmploymentModel employment) async {
    try {
      return await _client.request<EmploymentModel>(
        ApiConstants.userEmploymentEndpoint,
        method: 'POST',
        data: employment.toJson(),
        parser: (data) => EmploymentModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EmploymentModel> updateEmployment(int employmentId, EmploymentModel employment) async {
    try {
      return await _client.request<EmploymentModel>(
        "${ApiConstants.userEmploymentEndpoint}$employmentId/",
        method: 'PATCH',
        data: employment.toJson(),
        parser: (data) => EmploymentModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEmployment(int employmentId) async {
    try {
      await _client.request(
        "${ApiConstants.userEmploymentEndpoint}$employmentId/",
        method: 'DELETE',
        parser: (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Education Methods
  Future<List<EducationModel>> getEducationList() async {
    try {
      return await _client.request<List<EducationModel>>(
        ApiConstants.userEducationEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EducationModel.fromJson(e)).toList();
          }
          return <EducationModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EducationModel> addEducation(EducationModel education) async {
    try {
      return await _client.request<EducationModel>(
        ApiConstants.userEducationEndpoint,
        method: 'POST',
        data: education.toJson(),
        parser: (data) => EducationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EducationModel> updateEducation(int educationId, EducationModel education) async {
    try {
      return await _client.request<EducationModel>(
        "${ApiConstants.userEducationEndpoint}$educationId/",
        method: 'PATCH',
        data: education.toJson(),
        parser: (data) => EducationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEducation(int educationId) async {
    try {
      await _client.request(
        "${ApiConstants.userEducationEndpoint}$educationId/",
        method: 'DELETE',
        parser: (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Skills Methods
  Future<List<UserSkillModel>> getUserSkills() async {
    try {
      return await _client.request<List<UserSkillModel>>(
        ApiConstants.userSkillsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => UserSkillModel.fromJson(e)).toList();
          }
          return <UserSkillModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<MasterSkillModel> addMasterSkill(String name) async {
    try {
      return await _client.request<MasterSkillModel>(
        ApiConstants.masterSkillsEndpoint,
        method: 'POST',
        data: {'name': name},
        parser: (data) => MasterSkillModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSkillModel> addUserSkill(UserSkillModel skill) async {
    try {
      return await _client.request<UserSkillModel>(
        ApiConstants.userSkillsEndpoint,
        method: 'POST',
        data: skill.toJson(),
        parser: (data) => UserSkillModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserSkill(int skillId) async {
    try {
      await _client.request(
        "${ApiConstants.userSkillsEndpoint}$skillId/",
        method: 'DELETE',
        parser: (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MasterSkillModel>> getMasterSkills() async {
    try {
      return await _client.request<List<MasterSkillModel>>(
        ApiConstants.masterSkillsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => MasterSkillModel.fromJson(e)).toList();
          }
          return <MasterSkillModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Projects Methods
  Future<List<ProjectModel>> getProjectList() async {
    try {
      return await _client.request<List<ProjectModel>>(
        ApiConstants.userProjectsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => ProjectModel.fromJson(e)).toList();
          }
          return <ProjectModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProjectModel> addProject(ProjectModel project) async {
    try {
      return await _client.request<ProjectModel>(
        ApiConstants.userProjectsEndpoint,
        method: 'POST',
        data: project.toJson(),
        parser: (data) => ProjectModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProjectModel> updateProject(int projectId, Map<String, dynamic> data) async {
    try {
      return await _client.request<ProjectModel>(
        "${ApiConstants.userProjectsEndpoint}$projectId/",
        method: 'PATCH',
        data: data,
        parser: (data) => ProjectModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _client.request(
        "${ApiConstants.userProjectsEndpoint}$projectId/",
        method: 'DELETE',
        parser: (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Certifications Methods
  Future<List<CertificationModel>> getCertificationList() async {
    try {
      return await _client.request<List<CertificationModel>>(
        ApiConstants.userCertificationsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => CertificationModel.fromJson(e)).toList();
          }
          return <CertificationModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CertificationModel> addCertification(CertificationModel cert) async {
    try {
      return await _client.request<CertificationModel>(
        ApiConstants.userCertificationsEndpoint,
        method: 'POST',
        data: cert.toJson(),
        parser: (data) => CertificationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CertificationModel> updateCertification(int certId, Map<String, dynamic> data) async {
    try {
      return await _client.request<CertificationModel>(
        "${ApiConstants.userCertificationsEndpoint}$certId/",
        method: 'PATCH',
        data: data,
        parser: (data) => CertificationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCertification(int certId) async {
    try {
      await _client.request(
        "${ApiConstants.userCertificationsEndpoint}$certId/",
        method: 'DELETE',
        parser: (data) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> submitPortalFeedback({
    required String feedbackType,
    required int rating,
    required String message,
    String? screenshotPath,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'feedback_type': feedbackType,
        'rating': rating,
        'message': message,
      };

      if (screenshotPath != null && screenshotPath.isNotEmpty) {
        map['screenshot'] = await MultipartFile.fromFile(
          screenshotPath,
          filename: screenshotPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(map);

      return await _client.request(
        ApiConstants.portalFeedbackEndpoint,
        method: 'POST',
        data: formData,
        parser: (data) => data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Master Data Methods
  Future<List<EducationMasterModel>> getEducationTypes() async {
    return _fetchMasterData(ApiConstants.eduTypesMaster);
  }

  Future<List<EducationMasterModel>> getInstitutions() async {
    return _fetchMasterData(ApiConstants.institutionsMaster);
  }

  Future<List<EducationMasterModel>> getUniversities() async {
    return _fetchMasterData(ApiConstants.universitiesMaster);
  }

  Future<List<EducationMasterModel>> getCourses() async {
    return _fetchMasterData(ApiConstants.coursesMaster);
  }

  Future<List<EducationMasterModel>> getSpecializations() async {
    return _fetchMasterData(ApiConstants.specializationsMaster);
  }

  Future<List<EducationMasterModel>> getGradingSystems() async {
    return _fetchMasterData(ApiConstants.gradingMaster);
  }

  Future<List<EducationMasterModel>> getCourseTypes() async {
    return _fetchMasterData(ApiConstants.courseTypesMaster);
  }

  Future<List<EducationMasterModel>> getEmploymentTypes() async {
    return _fetchMasterData(ApiConstants.employmentTypesEndpoint);
  }

  Future<List<EducationMasterModel>> getSalaryUnits() async {
    try {
      return await _client.request<List<EducationMasterModel>>(
        ApiConstants.salaryUnitsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EducationMasterModel(
              id: e['id'],
              name: e['unit_name'] ?? e['department_name'] ?? e['name'] ?? '',
            )).toList();
          }
          return <EducationMasterModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EducationMasterModel>> getIndustries() async {
    try {
      return await _client.request<List<EducationMasterModel>>(
        ApiConstants.industriesEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EducationMasterModel(
              id: e['id'],
              name: e['industry_name'] ?? e['name'] ?? '',
            )).toList();
          }
          return <EducationMasterModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EducationMasterModel>> getDepartments() async {
    try {
      return await _client.request<List<EducationMasterModel>>(
        ApiConstants.departmentsEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EducationMasterModel(
              id: e['id'],
              name: e['department_name'] ?? e['name'] ?? '',
            )).toList();
          }
          return <EducationMasterModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EducationMasterModel>> _fetchMasterData(String endpoint) async {
    try {
      return await _client.request<List<EducationMasterModel>>(
        endpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => EducationMasterModel.fromJson(e)).toList();
          }
          return <EducationMasterModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<JobPreferenceReqModel> postJobPreferences(
      JobPreferenceReqModel preferences,
      ) async {
    try {
      return await _client.request<JobPreferenceReqModel>(
        ApiConstants.jobPreferencesEndpoint,
        method: 'POST',
        data: preferences.toJson(),
        parser: (data) => JobPreferenceReqModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobPreferenceReqModel>> getJobPreferences() async {
    try {
      return await _client.request<List<JobPreferenceReqModel>>(
        ApiConstants.jobPreferencesEndpoint,
        method: 'GET',
        parser: (data) {
          if (data is List) {
            return data.map((e) => JobPreferenceReqModel.fromJson(e)).toList();
          }
          return <JobPreferenceReqModel>[];
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}