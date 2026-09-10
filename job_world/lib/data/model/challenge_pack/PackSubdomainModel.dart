class PackDifficultyModel {
  final String difficulty;
  final int availableQuestions;

  PackDifficultyModel({
    required this.difficulty,
    required this.availableQuestions,
  });

  factory PackDifficultyModel.fromJson(Map<String, dynamic> json) {
    return PackDifficultyModel(
      difficulty: json['difficulty'] ?? '',
      availableQuestions: json['available_questions'] ?? 0,
    );
  }
}

class PackSubdomainModel {
  final int subdomainId;
  final String subdomainName;
  final List<PackDifficultyModel> difficulties;

  PackSubdomainModel({
    required this.subdomainId,
    required this.subdomainName,
    required this.difficulties,
  });

  int get totalQuestions => difficulties.fold(0, (sum, d) => sum + d.availableQuestions);

  factory PackSubdomainModel.fromJson(Map<String, dynamic> json) {
    final rawDiff = (json['difficulties'] as List?) ?? const [];
    return PackSubdomainModel(
      subdomainId: json['subdomain_id'] ?? 0,
      subdomainName: json['subdomain_name'] ?? '',
      difficulties: rawDiff.map((e) => PackDifficultyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
