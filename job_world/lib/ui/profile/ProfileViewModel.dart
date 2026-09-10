import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/networking_providers.dart';
import '../../data/model/profile/CertificationModel.dart';
import '../../data/model/profile/CvModel.dart';
import '../../data/model/profile/EducationModel.dart';
import '../../data/model/profile/EducationMasterModel.dart';
import '../../data/model/profile/EmploymentModel.dart';
import '../../data/model/profile/ProjectModel.dart';
import '../../data/model/profile/SkillModel.dart';
import '../../data/model/profile/UserProfileModel.dart';
import '../../data/model/profile/JobPreferenceModel.dart';
import '../../data/repositories/ProfileRepository.dart';

class ProfileState {
  final AsyncValue<UserProfileModel?> profile;
  final AsyncValue<List<CvModel>> cvs;
  final AsyncValue<List<EmploymentModel>> employments;
  final AsyncValue<List<EducationModel>> educations;
  final AsyncValue<List<UserSkillModel>> skills;
  final AsyncValue<List<ProjectModel>> projects;
  final AsyncValue<List<CertificationModel>> certifications;
  final AsyncValue<List<JobPreferenceReqModel>> jobPreferences;
  
  // Masters
  final AsyncValue<List<EducationMasterModel>> eduTypes;
  final AsyncValue<List<EducationMasterModel>> institutions;
  final AsyncValue<List<EducationMasterModel>> universities;
  final AsyncValue<List<EducationMasterModel>> courses;
  final AsyncValue<List<EducationMasterModel>> specializations;
  final AsyncValue<List<EducationMasterModel>> gradingSystems;
  final AsyncValue<List<EducationMasterModel>> courseTypes;
  final AsyncValue<List<EducationMasterModel>> employmentTypes;
  final AsyncValue<List<EducationMasterModel>> salaryUnits;
  final AsyncValue<List<EducationMasterModel>> industries;
  final AsyncValue<List<EducationMasterModel>> departments;
  final AsyncValue<List<MasterSkillModel>> masterSkills;

  final AsyncValue<void> updateStatus;
  final AsyncValue<void> uploadStatus;
  final AsyncValue<void> employmentActionStatus;
  final AsyncValue<void> educationActionStatus;
  final AsyncValue<void> skillActionStatus;
  final AsyncValue<void> projectActionStatus;
  final AsyncValue<void> certificationActionStatus;
  final AsyncValue<void> jobPreferenceActionStatus;

  ProfileState({
    this.profile = const AsyncValue.loading(),
    this.cvs = const AsyncValue.loading(),
    this.employments = const AsyncValue.loading(),
    this.educations = const AsyncValue.loading(),
    this.skills = const AsyncValue.loading(),
    this.projects = const AsyncValue.loading(),
    this.certifications = const AsyncValue.loading(),
    this.jobPreferences = const AsyncValue.loading(),
    this.eduTypes = const AsyncValue.loading(),
    this.institutions = const AsyncValue.loading(),
    this.universities = const AsyncValue.loading(),
    this.courses = const AsyncValue.loading(),
    this.specializations = const AsyncValue.loading(),
    this.gradingSystems = const AsyncValue.loading(),
    this.courseTypes = const AsyncValue.loading(),
    this.employmentTypes = const AsyncValue.loading(),
    this.salaryUnits = const AsyncValue.loading(),
    this.industries = const AsyncValue.loading(),
    this.departments = const AsyncValue.loading(),
    this.masterSkills = const AsyncValue.loading(),
    this.updateStatus = const AsyncValue.data(null),
    this.uploadStatus = const AsyncValue.data(null),
    this.employmentActionStatus = const AsyncValue.data(null),
    this.educationActionStatus = const AsyncValue.data(null),
    this.skillActionStatus = const AsyncValue.data(null),
    this.projectActionStatus = const AsyncValue.data(null),
    this.certificationActionStatus = const AsyncValue.data(null),
    this.jobPreferenceActionStatus = const AsyncValue.data(null),
  });

  ProfileState copyWith({
    AsyncValue<UserProfileModel?>? profile,
    AsyncValue<List<CvModel>>? cvs,
    AsyncValue<List<EmploymentModel>>? employments,
    AsyncValue<List<EducationModel>>? educations,
    AsyncValue<List<UserSkillModel>>? skills,
    AsyncValue<List<ProjectModel>>? projects,
    AsyncValue<List<CertificationModel>>? certifications,
    AsyncValue<List<JobPreferenceReqModel>>? jobPreferences,
    AsyncValue<List<EducationMasterModel>>? eduTypes,
    AsyncValue<List<EducationMasterModel>>? institutions,
    AsyncValue<List<EducationMasterModel>>? universities,
    AsyncValue<List<EducationMasterModel>>? courses,
    AsyncValue<List<EducationMasterModel>>? specializations,
    AsyncValue<List<EducationMasterModel>>? gradingSystems,
    AsyncValue<List<EducationMasterModel>>? courseTypes,
    AsyncValue<List<EducationMasterModel>>? employmentTypes,
    AsyncValue<List<EducationMasterModel>>? salaryUnits,
    AsyncValue<List<EducationMasterModel>>? industries,
    AsyncValue<List<EducationMasterModel>>? departments,
    AsyncValue<List<MasterSkillModel>>? masterSkills,
    AsyncValue<void>? updateStatus,
    AsyncValue<void>? uploadStatus,
    AsyncValue<void>? employmentActionStatus,
    AsyncValue<void>? educationActionStatus,
    AsyncValue<void>? skillActionStatus,
    AsyncValue<void>? projectActionStatus,
    AsyncValue<void>? certificationActionStatus,
    AsyncValue<void>? jobPreferenceActionStatus,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      cvs: cvs ?? this.cvs,
      employments: employments ?? this.employments,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      jobPreferences: jobPreferences ?? this.jobPreferences,
      eduTypes: eduTypes ?? this.eduTypes,
      institutions: institutions ?? this.institutions,
      universities: universities ?? this.universities,
      courses: courses ?? this.courses,
      specializations: specializations ?? this.specializations,
      gradingSystems: gradingSystems ?? this.gradingSystems,
      courseTypes: courseTypes ?? this.courseTypes,
      employmentTypes: employmentTypes ?? this.employmentTypes,
      salaryUnits: salaryUnits ?? this.salaryUnits,
      industries: industries ?? this.industries,
      departments: departments ?? this.departments,
      masterSkills: masterSkills ?? this.masterSkills,
      updateStatus: updateStatus ?? this.updateStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      employmentActionStatus: employmentActionStatus ?? this.employmentActionStatus,
      educationActionStatus: educationActionStatus ?? this.educationActionStatus,
      skillActionStatus: skillActionStatus ?? this.skillActionStatus,
      projectActionStatus: projectActionStatus ?? this.projectActionStatus,
      certificationActionStatus: certificationActionStatus ?? this.certificationActionStatus,
      jobPreferenceActionStatus: jobPreferenceActionStatus ?? this.jobPreferenceActionStatus,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileViewModel(repository);
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository)
      : super(ProfileState()) {
    fetchAllProfileData();
  }

  Future<void> fetchAllProfileData({bool force = false}) async {
    fetchProfile(force: force);
    fetchCvs(force: force);
    fetchEmployments(force: force);
    fetchEducations(force: force);
    fetchSkills(force: force);
    fetchProjects(force: force);
    fetchCertifications(force: force);
    fetchJobPreferences(force: force);
  }

  Future<void> fetchProfile({bool force = false}) async {
    if (!force && state.profile is AsyncData && state.profile.valueOrNull != null) return;
    state = state.copyWith(profile: const AsyncValue.loading());
    try {
      final profile = await _repository.getUserProfile();
      state = state.copyWith(profile: AsyncValue.data(profile));
    } catch (e, stack) {
      state = state.copyWith(profile: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchCvs({bool force = false}) async {
    if (!force && state.cvs is AsyncData && state.cvs.valueOrNull != null) return;
    state = state.copyWith(cvs: const AsyncValue.loading());
    try {
      final cvs = await _repository.getUserCvs();
      print("CV:$cvs");
      state = state.copyWith(cvs: AsyncValue.data(cvs));
    } catch (e, stack) {
      state = state.copyWith(cvs: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchEmployments({bool force = false}) async {
    if (!force && state.employments is AsyncData && state.employments.valueOrNull != null) return;
    state = state.copyWith(employments: const AsyncValue.loading());
    try {
      final employments = await _repository.getEmploymentList();
      state = state.copyWith(employments: AsyncValue.data(employments));
    } catch (e, stack) {
      state = state.copyWith(employments: AsyncValue.error(e, stack));
    }
  }

  Future<void> addEmployment(EmploymentModel employment) async {
    state = state.copyWith(employmentActionStatus: const AsyncValue.loading());
    try {
      final newEmployment = await _repository.addEmployment(employment);
      state.employments.whenData((list) {
        state = state.copyWith(
          employments: AsyncValue.data([...list, newEmployment]),
          employmentActionStatus: const AsyncValue.data(null),
        );
      });
      fetchEmployments();
    } catch (e, stack) {
      state = state.copyWith(employmentActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> updateEmployment(int employmentId, EmploymentModel employment) async {
    state = state.copyWith(employmentActionStatus: const AsyncValue.loading());
    try {
      final updatedEmployment = await _repository.updateEmployment(employmentId, employment);
      state.employments.whenData((list) {
        final newList = list.map((e) => e.id == employmentId ? updatedEmployment : e).toList();
        state = state.copyWith(
          employments: AsyncValue.data(newList),
          employmentActionStatus: const AsyncValue.data(null),
        );
      });
      fetchEmployments();
    } catch (e, stack) {
      state = state.copyWith(employmentActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> deleteEmployment(int employmentId) async {
    state = state.copyWith(employmentActionStatus: const AsyncValue.loading());
    try {
      await _repository.deleteEmployment(employmentId);
      state.employments.whenData((list) {
        final newList = list.where((e) => e.id != employmentId).toList();
        state = state.copyWith(
          employments: AsyncValue.data(newList),
          employmentActionStatus: const AsyncValue.data(null),
        );
      });
    } catch (e, stack) {
      state = state.copyWith(employmentActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchEducations({bool force = false}) async {
    if (!force && state.educations is AsyncData && state.educations.valueOrNull != null) return;
    state = state.copyWith(educations: const AsyncValue.loading());
    try {
      final educations = await _repository.getEducationList();
      state = state.copyWith(educations: AsyncValue.data(educations));
    } catch (e, stack) {
      state = state.copyWith(educations: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchEducationMasters({bool force = false}) async {
    if (!force && state.eduTypes is AsyncData && state.institutions is AsyncData) return;

    // Fetch each master individually to prevent one failure from blocking all dropdowns
    _fetchAndSetMaster(() => _repository.getEducationTypes(), (data) => state = state.copyWith(eduTypes: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getInstitutions(), (data) => state = state.copyWith(institutions: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getUniversities(), (data) => state = state.copyWith(universities: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getCourses(), (data) => state = state.copyWith(courses: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getSpecializations(), (data) => state = state.copyWith(specializations: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getGradingSystems(), (data) => state = state.copyWith(gradingSystems: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getCourseTypes(), (data) => state = state.copyWith(courseTypes: AsyncValue.data(data)));
  }

  Future<void> fetchJobPreferenceMasters({bool force = false}) async {
    if (!force && state.employmentTypes is AsyncData && state.salaryUnits is AsyncData) return;

    _fetchAndSetMaster(() => _repository.getEmploymentTypes(), (data) => state = state.copyWith(employmentTypes: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getSalaryUnits(), (data) => state = state.copyWith(salaryUnits: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getIndustries(), (data) => state = state.copyWith(industries: AsyncValue.data(data)));
    _fetchAndSetMaster(() => _repository.getDepartments(), (data) => state = state.copyWith(departments: AsyncValue.data(data)));
  }

  Future<void> _fetchAndSetMaster<T>(Future<T> Function() fetcher, void Function(T) setter) async {
    try {
      final data = await fetcher();
      setter(data);
    } catch (e) {
      // Keep as error state instead of stuck in loading
      debugPrint("Error fetching master: $e");
    }
  }

  Future<void> addEducation(EducationModel education) async {
    state = state.copyWith(educationActionStatus: const AsyncValue.loading());
    try {
      final newEducation = await _repository.addEducation(education);
      state.educations.whenData((list) {
        state = state.copyWith(
          educations: AsyncValue.data([...list, newEducation]),
          educationActionStatus: const AsyncValue.data(null),
        );
      });
      fetchEducations();
    } catch (e, stack) {
      state = state.copyWith(educationActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> updateEducation(int educationId, EducationModel education) async {
    state = state.copyWith(educationActionStatus: const AsyncValue.loading());
    try {
      final updatedEducation = await _repository.updateEducation(educationId, education);
      state.educations.whenData((list) {
        final newList = list.map((e) => e.id == educationId ? updatedEducation : e).toList();
        state = state.copyWith(
          educations: AsyncValue.data(newList),
          educationActionStatus: const AsyncValue.data(null),
        );
      });
      fetchEducations();
    } catch (e, stack) {
      state = state.copyWith(educationActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> deleteEducation(int educationId) async {
    state = state.copyWith(educationActionStatus: const AsyncValue.loading());
    try {
      await _repository.deleteEducation(educationId);
      state.educations.whenData((list) {
        final newList = list.where((e) => e.id != educationId).toList();
        state = state.copyWith(
          educations: AsyncValue.data(newList),
          educationActionStatus: const AsyncValue.data(null),
        );
      });
    } catch (e, stack) {
      state = state.copyWith(educationActionStatus: AsyncValue.error(e, stack));
    }
  }

  // Skills
  Future<void> fetchSkills({bool force = false}) async {
    if (!force && state.skills is AsyncData && state.skills.valueOrNull != null) return;
    state = state.copyWith(skills: const AsyncValue.loading());
    try {
      final skills = await _repository.getUserSkills();
      state = state.copyWith(skills: AsyncValue.data(skills));
    } catch (e, stack) {
      state = state.copyWith(skills: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchMasterSkills({bool force = false}) async {
    if (!force && state.masterSkills is AsyncData) return;
    try {
      final skills = await _repository.getMasterSkills();
      state = state.copyWith(masterSkills: AsyncValue.data(skills));
    } catch (e) {
      debugPrint("Error fetching master skills: $e");
    }
  }

  Future<void> addUserSkill(UserSkillModel skill) async {
    state = state.copyWith(skillActionStatus: const AsyncValue.loading());
    try {
      await _repository.addUserSkill(skill);
      fetchSkills();
      state = state.copyWith(skillActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(skillActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> deleteUserSkill(int id) async {
    state = state.copyWith(skillActionStatus: const AsyncValue.loading());
    try {
      await _repository.deleteUserSkill(id);
      fetchSkills();
      state = state.copyWith(skillActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(skillActionStatus: AsyncValue.error(e, stack));
    }
  }

  // Projects
  Future<void> fetchProjects({bool force = false}) async {
    if (!force && state.projects is AsyncData && state.projects.valueOrNull != null) return;
    state = state.copyWith(projects: const AsyncValue.loading());
    try {
      final projects = await _repository.getProjectList();
      state = state.copyWith(projects: AsyncValue.data(projects));
    } catch (e, stack) {
      state = state.copyWith(projects: AsyncValue.error(e, stack));
    }
  }

  Future<void> addProject(ProjectModel project) async {
    state = state.copyWith(projectActionStatus: const AsyncValue.loading());
    try {
      await _repository.addProject(project);
      fetchProjects();
      state = state.copyWith(projectActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(projectActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> updateProject(int id, ProjectModel project) async {
    state = state.copyWith(projectActionStatus: const AsyncValue.loading());
    try {
      await _repository.updateProject(id, project.toJson());
      fetchProjects();
      state = state.copyWith(projectActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(projectActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> deleteProject(int id) async {
    state = state.copyWith(projectActionStatus: const AsyncValue.loading());
    try {
      await _repository.deleteProject(id);
      fetchProjects();
      state = state.copyWith(projectActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(projectActionStatus: AsyncValue.error(e, stack));
    }
  }

  // Certifications
  Future<void> fetchCertifications({bool force = false}) async {
    if (!force && state.certifications is AsyncData && state.certifications.valueOrNull != null) return;
    state = state.copyWith(certifications: const AsyncValue.loading());
    try {
      final certifications = await _repository.getCertificationList();
      state = state.copyWith(certifications: AsyncValue.data(certifications));
    } catch (e, stack) {
      state = state.copyWith(certifications: AsyncValue.error(e, stack));
    }
  }

  Future<void> addCertification(CertificationModel cert) async {
    state = state.copyWith(certificationActionStatus: const AsyncValue.loading());
    try {
      await _repository.addCertification(cert);
      fetchCertifications();
      state = state.copyWith(certificationActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(certificationActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> updateCertification(int id, CertificationModel cert) async {
    state = state.copyWith(certificationActionStatus: const AsyncValue.loading());
    try {
      await _repository.updateCertification(id, cert.toJson());
      fetchCertifications();
      state = state.copyWith(certificationActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(certificationActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> deleteCertification(int id) async {
    state = state.copyWith(certificationActionStatus: const AsyncValue.loading());
    try {
      await _repository.deleteCertification(id);
      fetchCertifications();
      state = state.copyWith(certificationActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(certificationActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> updateProfile(int profileId, Map<String, dynamic> data) async {
    state = state.copyWith(updateStatus: const AsyncValue.loading());
    try {
      final updatedProfile = await _repository.updateProfile(profileId, data);
      state = state.copyWith(
        profile: AsyncValue.data(updatedProfile),
        updateStatus: const AsyncValue.data(null),
      );
    } catch (e, stack) {
      state = state.copyWith(updateStatus: AsyncValue.error(e, stack));
    }
  }

  Future<dynamic> submitPortalFeedback({
    required String feedbackType,
    required int rating,
    required String message,
    String? screenshotPath,
  }) async {
    try {
      return await _repository.submitPortalFeedback(
        feedbackType: feedbackType,
        rating: rating,
        message: message,
        screenshotPath: screenshotPath,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadResume(String filePath) async {
    state = state.copyWith(uploadStatus: const AsyncValue.loading());
    try {
      await _repository.uploadCv(filePath);
      state = state.copyWith(uploadStatus: const AsyncValue.data(null));
      fetchCvs(force: true);
    } catch (e, stack) {
      state = state.copyWith(uploadStatus: AsyncValue.error(e, stack));
      rethrow;
    }
  }

  Future<void> addJobPreference(JobPreferenceReqModel preference) async {
    state = state.copyWith(jobPreferenceActionStatus: const AsyncValue.loading());
    try {
      await _repository.postJobPreferences(preference);
      fetchJobPreferences();
      state = state.copyWith(jobPreferenceActionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(jobPreferenceActionStatus: AsyncValue.error(e, stack));
    }
  }

  Future<void> fetchJobPreferences({bool force = false}) async {
    if (!force && state.jobPreferences is AsyncData && state.jobPreferences.valueOrNull != null) return;
    state = state.copyWith(jobPreferences: const AsyncValue.loading());
    try {
      final preferences = await _repository.getJobPreferences();
      state = state.copyWith(jobPreferences: AsyncValue.data(preferences));
    } catch (e, stack) {
      state = state.copyWith(jobPreferences: AsyncValue.error(e, stack));
    }
  }
}

extension ProfileCompletionExtension on ProfileState {
  double get completionPercentage {
    final p = profile.valueOrNull;
    if (p == null) return 0.0;

    double score = 0.0;

    // 1. Basic Info (25%)
    if (p.firstName.isNotEmpty && p.lastName.isNotEmpty) score += 5.0;
    if (p.phoneNumber.isNotEmpty) score += 5.0;
    if (p.city.isNotEmpty || p.state.isNotEmpty) score += 5.0;
    if (p.gender?.isNotEmpty == true || p.dateOfBirth?.isNotEmpty == true) score += 5.0;
    if (p.profileSummary?.isNotEmpty == true) score += 5.0;

    // 2. Work Experience (20%)
    final empList = employments.valueOrNull ?? [];
    if (empList.isNotEmpty || p.candidateType?.toLowerCase() == 'fresher') {
      score += 20.0;
    }

    // 3. Education (20%)
    final eduList = educations.valueOrNull ?? [];
    if (eduList.isNotEmpty) {
      score += 20.0;
    }

    // 4. Skills (15%)
    final skillList = skills.valueOrNull ?? [];
    if (skillList.isNotEmpty) {
      score += 15.0;
    }

    // 5. Resume / CV or Projects (20%)
    final cvList = cvs.valueOrNull ?? [];
    final projList = projects.valueOrNull ?? [];
    if (cvList.isNotEmpty || projList.isNotEmpty) {
      score += 20.0;
    }

    return score.clamp(0.0, 100.0);
  }
}