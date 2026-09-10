class ExamTitleModel {
  final int id;
  final String name;
  final int domain;

  ExamTitleModel({
    required this.id,
    required this.name,
    required this.domain,
  });

  factory ExamTitleModel.fromJson(Map<String, dynamic> json) {
    return ExamTitleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      domain: json['domain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
    };
  }
}
