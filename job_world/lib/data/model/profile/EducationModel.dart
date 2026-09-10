class EducationModel {
  final int? id;
  final int? user;
  final int educationType;
  final int institution;
  final int? university;
  final int? course;
  final int? specialization;
  final int? courseType;
  final int gradingSystem;
  final int startYear;
  final int? endYear;
  final double marks;

  // Display names from GET response
  final String? educationTypeName;
  final String? institutionName;
  final String? universityName;
  final String? courseName;
  final String? specializationName;
  final String? courseTypeName;
  final String? gradingSystemName;

  EducationModel({
    this.id,
    this.user,
    required this.educationType,
    required this.institution,
    this.university,
    this.course,
    this.specialization,
    this.courseType,
    required this.gradingSystem,
    required this.startYear,
    this.endYear,
    required this.marks,
    this.educationTypeName,
    this.institutionName,
    this.universityName,
    this.courseName,
    this.specializationName,
    this.courseTypeName,
    this.gradingSystemName,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'],
      user: json['user'],
      educationType: json['education_type'] ?? 0,
      institution: json['institution'] ?? 0,
      university: json['university'],
      course: json['course'],
      specialization: json['specialization'],
      courseType: json['course_type'],
      gradingSystem: json['grading_system'] ?? 0,
      startYear: json['start_year'] ?? 0,
      endYear: json['end_year'],
      marks: (json['marks'] ?? 0.0).toDouble(),
      educationTypeName: json['education_type_name'],
      institutionName: json['institution_name'],
      universityName: json['university_name'],
      courseName: json['course_name'],
      specializationName: json['specialization_name'],
      courseTypeName: json['course_type_name'],
      gradingSystemName: json['grading_system_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'education_type': educationType,
      'institution': institution,
      'university': university,
      'course': course,
      'specialization': specialization,
      'course_type': courseType,
      'grading_system': gradingSystem,
      'start_year': startYear,
      'end_year': endYear,
      'marks': marks,
    };
  }
}
