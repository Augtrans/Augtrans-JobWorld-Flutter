class EmploymentModel {
  final int? id;
  final bool isCurrent;
  final String organizationName;
  final String designation;
  final String joinedDate;
  final String? workedTill;
  final String jobProfile;
  final int noticePeriodDays;
  final String location;
  final int? user;

  EmploymentModel({
    this.id,
    required this.isCurrent,
    required this.organizationName,
    required this.designation,
    required this.joinedDate,
    this.workedTill,
    required this.jobProfile,
    required this.noticePeriodDays,
    required this.location,
    this.user,
  });

  factory EmploymentModel.fromJson(Map<String, dynamic> json) {
    return EmploymentModel(
      id: json['id'],
      isCurrent: json['is_current'] ?? false,
      organizationName: json['organization_name'] ?? '',
      designation: json['designation'] ?? '',
      joinedDate: json['joined_date'] ?? '',
      workedTill: json['worked_till'],
      jobProfile: json['job_profile'] ?? '',
      noticePeriodDays: json['notice_period_days'] ?? 0,
      location: json['location'] ?? '',
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'is_current': isCurrent,
      'organization_name': organizationName,
      'designation': designation,
      'joined_date': joinedDate,
      'worked_till': workedTill,
      'job_profile': jobProfile,
      'notice_period_days': noticePeriodDays,
      'location': location,
      if (user != null) 'user': user,
    };
  }
}
