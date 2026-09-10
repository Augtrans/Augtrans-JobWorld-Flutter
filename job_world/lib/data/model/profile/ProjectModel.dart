class ProjectModel {
  final int? id;
  final String title;
  final String client;
  final String projectStatus;
  final String startDate;
  final String? endDate;
  final String description;
  final String? siteUrl;
  final int? user;
  final int? employment;
  final List<int> skillsUsed;
  final List<String>? skillsUsedNames;

  ProjectModel({
    this.id,
    required this.title,
    required this.client,
    required this.projectStatus,
    required this.startDate,
    this.endDate,
    required this.description,
    this.siteUrl,
    this.user,
    this.employment,
    required this.skillsUsed,
    this.skillsUsedNames,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'] ?? '',
      client: json['client'] ?? '',
      projectStatus: json['project_status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      description: json['description'] ?? '',
      siteUrl: json['site_url'],
      user: json['user'],
      employment: json['employment'],
      skillsUsed: List<int>.from(json['skills_used'] ?? []),
      skillsUsedNames: List<String>.from(json['skills_used_names'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'client': client,
      'project_status': projectStatus,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
      'site_url': siteUrl,
      'user': user,
      'employment': employment,
      'skills_used': skillsUsed,
    };
  }
}
