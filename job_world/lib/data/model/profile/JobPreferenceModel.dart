class JobPreferenceReqModel {
  final int? id;
  final int user;
  final int industry;
  final int department;
  final String jobRole;
  final String jobType;
  final int desiredEmploymentType;
  final String preferredShift;
  final String preferredWorkLocations;
  final int salaryUnit;
  final double expectedSalary;

  JobPreferenceReqModel({
    this.id,
    required this.user,
    required this.industry,
    required this.department,
    required this.jobRole,
    required this.jobType,
    required this.desiredEmploymentType,
    required this.preferredShift,
    required this.preferredWorkLocations,
    required this.salaryUnit,
    required this.expectedSalary,
  });

  factory JobPreferenceReqModel.fromJson(Map<String, dynamic> json) {
    return JobPreferenceReqModel(
      id: json['id'],
      user: json['user'] ?? 0,
      industry: json['industry'] ?? 0,
      department: json['department'] ?? 0,
      jobRole: json['job_role'] ?? '',
      jobType: json['job_type'] ?? '',
      desiredEmploymentType: json['desired_employment_type'] ?? 0,
      preferredShift: json['preferred_shift'] ?? '',
      preferredWorkLocations: json['preferred_work_locations'] ?? '',
      salaryUnit: json['salary_unit'] ?? 0,
      expectedSalary: (json['expected_salary'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user': user,
      'industry': industry,
      'department': department,
      'job_role': jobRole,
      'desired_employment_type': desiredEmploymentType,
      'preferred_shift': preferredShift,
      'preferred_work_locations': preferredWorkLocations,
      'salary_unit': salaryUnit,
      'expected_salary': expectedSalary,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}