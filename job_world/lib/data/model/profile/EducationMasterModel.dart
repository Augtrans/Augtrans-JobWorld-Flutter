class EducationMasterModel {
  final int id;
  final String name;

  EducationMasterModel({
    required this.id,
    required this.name,
  });

  factory EducationMasterModel.fromJson(Map<String, dynamic> json) {
    return EducationMasterModel(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
