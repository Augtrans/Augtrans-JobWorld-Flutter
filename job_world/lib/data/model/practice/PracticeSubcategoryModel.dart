class PracticeSubcategoryModel {
  final int id;
  final String subcategoryName;
  final int totalQuestions;
  final int easyCount;
  final int mediumCount;
  final int hardCount;
  final bool solved;
  final num score;
  final String summary;

  PracticeSubcategoryModel({
    required this.id,
    required this.subcategoryName,
    required this.totalQuestions,
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
    required this.solved,
    required this.score,
    required this.summary,
  });

  factory PracticeSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return PracticeSubcategoryModel(
      id: json['id'] ?? 0,
      subcategoryName: json['subcat_name'] ?? json['name'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      easyCount: json['easy_count'] ?? 0,
      mediumCount: json['medium_count'] ?? 0,
      hardCount: json['hard_count'] ?? 0,
      solved: json['solved'] ?? false,
      score: json['score'] ?? 0,
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcat_name': subcategoryName,
      'total_questions': totalQuestions,
      'easy_count': easyCount,
      'medium_count': mediumCount,
      'hard_count': hardCount,
      'solved': solved,
      'score': score,
      'summary': summary,
    };
  }
}
