class McqExamModel {
  final int id;
  final String titleName;
  final bool isAttempted;
  final double score;
  final List<dynamic> requiredSkills;
  final String? customTitle;
  final String description;
  final String difficulty;
  final bool isSelfAssessment;
  final int totalDurationMinutes;
  final int passPercentage;
  final String? createdAt;
  final int noOfQuestions;
  final int? title;
  final dynamic job;
  final dynamic lesson;
  final int? createdBy;
  final int? packId;

  McqExamModel({
    required this.id,
    required this.titleName,
    required this.isAttempted,
    required this.score,
    required this.requiredSkills,
    this.customTitle,
    required this.description,
    required this.difficulty,
    required this.isSelfAssessment,
    required this.totalDurationMinutes,
    required this.passPercentage,
    this.createdAt,
    required this.noOfQuestions,
    this.title,
    this.job,
    this.lesson,
    this.createdBy,
    this.packId,
  });

  McqExamModel copyWith({int? packId}) {
    return McqExamModel(
      id: id,
      titleName: titleName,
      isAttempted: isAttempted,
      score: score,
      requiredSkills: requiredSkills,
      customTitle: customTitle,
      description: description,
      difficulty: difficulty,
      isSelfAssessment: isSelfAssessment,
      totalDurationMinutes: totalDurationMinutes,
      passPercentage: passPercentage,
      createdAt: createdAt,
      noOfQuestions: noOfQuestions,
      title: title,
      job: job,
      lesson: lesson,
      createdBy: createdBy,
      packId: packId ?? this.packId,
    );
  }

  factory McqExamModel.fromJson(Map<String, dynamic> json) {
    return McqExamModel(
      id: json['id'] ?? 0,
      titleName: json['title_name'] ?? json['custom_title'] ?? 'MCQ Exam',
      isAttempted: json['is_attempted'] ?? false,
      score: (json['score'] ?? 0.0).toDouble(),
      requiredSkills: (json['required_skills'] as List?) ?? [],
      customTitle: json['custom_title'],
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'B',
      isSelfAssessment: json['is_self_assessment'] ?? true,
      totalDurationMinutes: json['total_duration_minutes'] ?? 15,
      passPercentage: json['pass_percentage'] ?? 50,
      createdAt: json['created_at'],
      noOfQuestions: json['no_of_questions'] ?? 10,
      title: json['title'],
      job: json['job'],
      lesson: json['lesson'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_name': titleName,
      'is_attempted': isAttempted,
      'score': score,
      'required_skills': requiredSkills,
      'custom_title': customTitle,
      'description': description,
      'difficulty': difficulty,
      'is_self_assessment': isSelfAssessment,
      'total_duration_minutes': totalDurationMinutes,
      'pass_percentage': passPercentage,
      'created_at': createdAt,
      'no_of_questions': noOfQuestions,
      'title': title,
      'job': job,
      'lesson': lesson,
      'created_by': createdBy,
    };
  }
}
