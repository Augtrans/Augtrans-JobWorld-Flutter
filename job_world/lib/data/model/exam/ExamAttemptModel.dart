class ExamAttemptModel {
  final int id;
  final String? startTime;
  final String? endTime;
  final bool isCompleted;
  final String totalScore;
  final String averageQuestionTime;
  final String performanceScore;
  final int exam;

  ExamAttemptModel({
    required this.id,
    this.startTime,
    this.endTime,
    required this.isCompleted,
    required this.totalScore,
    required this.averageQuestionTime,
    required this.performanceScore,
    required this.exam,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) {
    return ExamAttemptModel(
      id: json['id'] ?? 0,
      startTime: json['start_time'],
      endTime: json['end_time'],
      isCompleted: json['is_completed'] ?? false,
      totalScore: json['total_score']?.toString() ?? '0.00',
      averageQuestionTime: json['average_question_time']?.toString() ?? '0.00',
      performanceScore: json['performance_score']?.toString() ?? '0.00',
      exam: json['exam'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'is_completed': isCompleted,
      'total_score': totalScore,
      'average_question_time': averageQuestionTime,
      'performance_score': performanceScore,
      'exam': exam,
    };
  }
}
