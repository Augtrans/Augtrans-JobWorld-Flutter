class ExamAnswerModel {
  final int question;
  final int? selectedOption;
  final String? answerText;
  final String? answerImage;
  final String questionStartTime;
  final String questionEndTime;

  ExamAnswerModel({
    required this.question,
    this.selectedOption,
    this.answerText,
    this.answerImage,
    required this.questionStartTime,
    required this.questionEndTime,
  });

  factory ExamAnswerModel.fromJson(Map<String, dynamic> json) {
    return ExamAnswerModel(
      question: json['question'] ?? 0,
      selectedOption: json['selected_option'],
      answerText: json['answer_text'],
      answerImage: json['answer_image'],
      questionStartTime: json['question_start_time'] ?? '',
      questionEndTime: json['question_end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'selected_option': selectedOption,
      'answer_text': answerText,
      'answer_image': answerImage,
      'question_start_time': questionStartTime,
      'question_end_time': questionEndTime,
    };
  }
}
