class ApiConstants {
  ApiConstants._();

  static const String loginEndpoint = '/user/login/';
  static const String registerOrgEndpoint = '/user/masters/organizations/';
  static const String registerHrHeadEndpoint = '/user/register/';
  static const String allOrgRoleDropdownEndpoint = '/user/masters/roles/';
  static const String userRegisterEndpoint = '/user/register/';
  static const String allOrgDropdownEndpoint = '/user/masters/organizations/';
  static const String allDeptDropdownEndpoint = '/user/profile/user-department/';
  static const String allReportManDropdownEndpoint = '/user/users/';
  static const String userLoginEndpoint = '/user/login/';
  static const String userCanRegisterEndpoint = '/user/register/';
  static const String userVerifyOTPEndpoint = '/user/verify-otp/';
  static const String userProfileEndpoint = '/user/profile/user-profile/';
  static const String userEmploymentEndpoint = '/user/profile/employment/';
  static const String userEducationEndpoint = '/user/profile/education/';
  static const String userSkillsEndpoint = '/user/user-skills/';
  static const String masterSkillsEndpoint = '/user/masters/skills/';
  static const String userProjectsEndpoint = '/user/profile/projects/';
  static const String userCertificationsEndpoint = '/user/certifications/';
  static const String uploadCvEndpoint = '/user/cvs/';
  static const String jobPreferencesEndpoint = '/jobpost/job-preferences/';
  
  // Job Post / Preferences Masters
  static const String employmentTypesEndpoint = '/jobpost/employment-types/';
  static const String salaryUnitsEndpoint = '/jobpost/salary-units/';
  static const String industriesEndpoint = '/jobpost/industries/';
  static const String departmentsEndpoint = '/jobpost/departments/'; // Added based on typical flow

  // Masters
  static const String eduTypesMaster = '/user/masters/edu-types/';
  static const String institutionsMaster = '/user/masters/edu-types/institutions/';
  static const String universitiesMaster = '/user/masters/edu-types/universities/';
  static const String coursesMaster = '/user/masters/edu-types/courses/';
  static const String specializationsMaster = '/user/masters/edu-types/specializations/';
  static const String gradingMaster = '/user/masters/edu-types/grading/';
  static const String courseTypesMaster = '/user/masters/edu-types/course_types/';

  // Resume Builder
  static const String resumeTemplatesEndpoint = '/user/templates/';
  static const String jdFitmentEndpoint = '/user/jd-fitment/';
  static const String portalFeedbackEndpoint = '/user/portal-feedback/';

  // Practice
  static const String practiceCategoriesEndpoint = '/practice/categories/';
  static const String practiceSubcategoriesEndpoint = '/practice/subcategories/';
  static const String practiceQuestionsSuffix = '/questions/';

  // Exams
  static const String examExamsEndpoint = '/exam/exams/';
  static const String examExamsQuestionsEndpoint = '/exam/exams-questions/';
  static const String examStartExamEndpoint = '/exam/start_exam/';
  static const String examAnswersBulkSubmitEndpoint = '/exam/answers-submit/bulk-submit/';
  static const String examTitlesEndpoint = '/exam/exam-titles/';

  // Challenge Packs
  static const String challengePacksEndpoint = '/exam/packs/';
  static const String challengePackMcqEndpoint = '/exam/packs/mcq/';
  static const String challengePackCodingEndpoint = '/exam/packs/coding/';
  static const String challengePackSubdomainExamsEndpoint = '/exam/packs/subdomain-exams/';
  static const String challengePackSubdomainCodingEndpoint = '/exam/packs/subdomain-coding/';

  // AI Interview
  static const String botInterviewConfigsEndpoint = '/interview/bot-interview-configs/';
  static const String startInterviewSessionEndpoint = '/interview/start-session/';

  // Wallet
  static const String walletEndpoint = '/wallets/wallet/';

}