class PracticeCategoryModel {
  final int id;
  final int solvedCount;
  final int totalCount;
  final String categoryName;
  final String? createdAt;
  final String? updatedAt;

  PracticeCategoryModel({
    required this.id,
    required this.solvedCount,
    required this.totalCount,
    required this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory PracticeCategoryModel.fromJson(Map<String, dynamic> json) {
    return PracticeCategoryModel(
      id: json['id'] ?? 0,
      solvedCount: json['solved_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      categoryName: json['Catg_name'] ?? json['catg_name'] ?? json['category_name'] ?? json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solved_count': solvedCount,
      'total_count': totalCount,
      'Catg_name': categoryName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
