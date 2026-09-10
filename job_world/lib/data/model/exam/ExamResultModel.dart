class ExamResultModel {
  final int id;
  final int exam;
  final bool isCompleted;
  final String totalScore;
  final String averageQuestionTime;
  final String performanceScore;
  final String? examTitle;
  final String? difficulty;
  final String? source;
  final Map<String, dynamic>? reward;

  ExamResultModel({
    required this.id,
    required this.exam,
    required this.isCompleted,
    required this.totalScore,
    required this.averageQuestionTime,
    required this.performanceScore,
    this.examTitle,
    this.difficulty,
    this.source,
    this.reward,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      id: json['id'] ?? 0,
      exam: json['exam'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      totalScore: json['total_score']?.toString() ?? '0.00',
      averageQuestionTime: json['average_question_time']?.toString() ?? '0.00',
      performanceScore: json['performance_score']?.toString() ?? '0.00',
      examTitle: json['exam_title'],
      difficulty: json['difficulty'],
      source: json['source'],
      reward: json['reward'] is Map<String, dynamic> ? json['reward'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam': exam,
      'is_completed': isCompleted,
      'total_score': totalScore,
      'average_question_time': averageQuestionTime,
      'performance_score': performanceScore,
      'exam_title': examTitle,
      'difficulty': difficulty,
      'source': source,
      'reward': reward,
    };
  }
}
