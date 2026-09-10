class PackDomainModel {
  final int id;
  final String name;

  PackDomainModel({
    required this.id,
    required this.name,
  });

  factory PackDomainModel.fromJson(Map<String, dynamic> json) {
    return PackDomainModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ChallengePackTypeModel {
  final String sourceType;
  final List<PackDomainModel> items;

  ChallengePackTypeModel({
    required this.sourceType,
    required this.items,
  });

  bool get isMcq => sourceType.toUpperCase() == 'MCQ';

  factory ChallengePackTypeModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['domains'] as List?) ?? (json['categories'] as List?) ?? const [];
    return ChallengePackTypeModel(
      sourceType: json['source_type'] ?? '',
      items: rawItems.map((e) => PackDomainModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
