class PackSubcategoryModel {
  final int id;
  final String subcatName;

  PackSubcategoryModel({
    required this.id,
    required this.subcatName,
  });

  factory PackSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return PackSubcategoryModel(
      id: json['id'] ?? 0,
      subcatName: json['subcat_name'] ?? json['name'] ?? '',
    );
  }
}
