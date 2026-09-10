import 'McqQuestionDetailsModel.dart';

class McqExamQuestionModel {
  final int id;
  final int exam;
  final int question;
  final int order;
  final McqQuestionDetailsModel questionDetails;

  McqExamQuestionModel({
    required this.id,
    required this.exam,
    required this.question,
    required this.order,
    required this.questionDetails,
  });

  factory McqExamQuestionModel.fromJson(Map<String, dynamic> json) {
    return McqExamQuestionModel(
      id: json['id'] ?? 0,
      exam: json['exam'] ?? 0,
      question: json['question'] ?? 0,
      order: json['order'] ?? 0,
      questionDetails: McqQuestionDetailsModel.fromJson(
        json['question_details'] is Map<String, dynamic>
            ? json['question_details']
            : {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam': exam,
      'question': question,
      'order': order,
      'question_details': questionDetails.toJson(),
    };
  }
}
