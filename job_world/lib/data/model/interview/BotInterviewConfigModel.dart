class BotInterviewConfigModel {
  final int configId;
  final String examTitle;
  final String difficulty;

  BotInterviewConfigModel({
    required this.configId,
    required this.examTitle,
    required this.difficulty,
  });

  factory BotInterviewConfigModel.fromJson(Map<String, dynamic> json) {
    return BotInterviewConfigModel(
      configId: json['config_id'] ?? 0,
      examTitle: json['exam_title'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'config_id': configId,
      'exam_title': examTitle,
      'difficulty': difficulty,
    };
  }

  /// Display label used in the focus-area dropdown, e.g. "AI Solutions Architect • Beginner".
  String get label => "$examTitle • $difficulty";
}
