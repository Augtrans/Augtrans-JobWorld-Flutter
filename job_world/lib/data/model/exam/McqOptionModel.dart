class McqOptionModel {
  final int id;
  final String text;
  final String? image;
  final bool isCorrect;

  McqOptionModel({
    required this.id,
    required this.text,
    this.image,
    required this.isCorrect,
  });

  factory McqOptionModel.fromJson(Map<String, dynamic> json) {
    return McqOptionModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      image: json['image'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'image': image,
      'is_correct': isCorrect,
    };
  }
}
