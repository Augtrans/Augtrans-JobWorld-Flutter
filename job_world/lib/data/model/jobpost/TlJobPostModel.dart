class TlJobPostModel {
  final int id;
  final int org;
  final String jobTitle;
  final int employmentType;
  final int workMode;
  final String jobDescription;
  final List<int> requiredSkills;
  final int minYoe;
  final int maxYoe;
  final int salaryUnit;
  final num budget;
  final List<int> continents;
  final List<int> countries;
  final List<int> availableLocation;
  final bool allowRelocation;
  final List<int> qualification;
  final int numberOfVacancy;
  final bool jobpostLock;
  final int? cvCriteria;
  final int? assignedRecruiter;
  final int? assignedTl;
  final String? tat;
  final String status;
  final String remark;
  final bool jdApproved;
  final String approvalComment;
  final String approvalStatus;
  final int department;
  final bool tatReminderSent;
  final String createdAt;
  final String orgName;
  final String departmentName;
  final String? recruiterName;
  final String? tlName;
  final String? managerName;
  final List<String> requiredSkillsNames;
  final List<String> locationNames;
  final String employmentTypeName;
  final List<String> continentNames;
  final List<String> countryNames;
  final String statusDisplay;
  final bool isExpired;
  final String postedBy;
  final String postedByRole;

  const TlJobPostModel({
    required this.id,
    required this.org,
    required this.jobTitle,
    required this.employmentType,
    required this.workMode,
    required this.jobDescription,
    required this.requiredSkills,
    required this.minYoe,
    required this.maxYoe,
    required this.salaryUnit,
    required this.budget,
    required this.continents,
    required this.countries,
    required this.availableLocation,
    required this.allowRelocation,
    required this.qualification,
    required this.numberOfVacancy,
    required this.jobpostLock,
    this.cvCriteria,
    this.assignedRecruiter,
    this.assignedTl,
    this.tat,
    required this.status,
    required this.remark,
    required this.jdApproved,
    required this.approvalComment,
    required this.approvalStatus,
    required this.department,
    required this.tatReminderSent,
    required this.createdAt,
    required this.orgName,
    required this.departmentName,
    this.recruiterName,
    this.tlName,
    this.managerName,
    required this.requiredSkillsNames,
    required this.locationNames,
    required this.employmentTypeName,
    required this.continentNames,
    required this.countryNames,
    required this.statusDisplay,
    required this.isExpired,
    required this.postedBy,
    required this.postedByRole,
  });

  static List<int> _intList(dynamic v) =>
      (v as List? ?? const []).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();

  static List<String> _stringList(dynamic v) =>
      (v as List? ?? const []).map((e) => e.toString()).toList();

  factory TlJobPostModel.fromJson(Map<String, dynamic> json) {
    return TlJobPostModel(
      id: json['id'] ?? 0,
      org: json['org'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      employmentType: json['employment_type'] ?? 0,
      workMode: json['work_mode'] ?? 0,
      jobDescription: json['job_description'] ?? '',
      requiredSkills: _intList(json['required_skills']),
      minYoe: json['min_yoe'] ?? 0,
      maxYoe: json['max_yoe'] ?? 0,
      salaryUnit: json['salary_unit'] ?? 0,
      budget: json['budget'] ?? 0,
      continents: _intList(json['continents']),
      countries: _intList(json['countries']),
      availableLocation: _intList(json['available_location']),
      allowRelocation: json['allow_relocation'] ?? false,
      qualification: _intList(json['qualification']),
      numberOfVacancy: json['number_of_vacancy'] ?? 0,
      jobpostLock: json['jobpost_lock'] ?? false,
      cvCriteria: json['cv_criteria'],
      assignedRecruiter: json['assigned_recruiter'],
      assignedTl: json['assigned_tl'],
      tat: json['tat'],
      status: json['status']?.toString() ?? '',
      remark: json['remark'] ?? '',
      jdApproved: json['jd_approved'] ?? false,
      approvalComment: json['approval_comment'] ?? '',
      approvalStatus: json['approval_status'] ?? '',
      department: json['department'] ?? 0,
      tatReminderSent: json['tat_reminder_sent'] ?? false,
      createdAt: json['created_at'] ?? '',
      orgName: json['org_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      recruiterName: json['recruiter_name'],
      tlName: json['tl_name'],
      managerName: json['manager_name'],
      requiredSkillsNames: _stringList(json['required_skills_names']),
      locationNames: _stringList(json['location_names']),
      employmentTypeName: json['employment_type_name'] ?? '',
      continentNames: _stringList(json['continent_names']),
      countryNames: _stringList(json['country_names']),
      statusDisplay: json['status_display'] ?? '',
      isExpired: json['is_expired'] ?? false,
      postedBy: json['posted_by'] ?? '',
      postedByRole: json['posted_by_role'] ?? '',
    );
  }
}
