import 'McqOptionModel.dart';

class McqQuestionDetailsModel {
  final int id;
  final String questionType;
  final String text;
  final String? image;
  final String? skill;
  final String difficulty;
  final List<McqOptionModel> options;
  final int? category;

  McqQuestionDetailsModel({
    required this.id,
    required this.questionType,
    required this.text,
    this.image,
    this.skill,
    required this.difficulty,
    required this.options,
    this.category,
  });

  factory McqQuestionDetailsModel.fromJson(Map<String, dynamic> json) {
    return McqQuestionDetailsModel(
      id: json['id'] ?? 0,
      questionType: json['question_type'] ?? 'MCQ',
      text: json['text'] ?? '',
      image: json['image'],
      skill: json['skill'],
      difficulty: json['difficulty'] ?? 'B',
      options: (json['options'] as List?)
              ?.map((e) => McqOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_type': questionType,
      'text': text,
      'image': image,
      'skill': skill,
      'difficulty': difficulty,
      'options': options.map((e) => e.toJson()).toList(),
      'category': category,
    };
  }
}
