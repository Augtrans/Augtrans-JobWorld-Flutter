class PracticeQuestionModel {
  final int id;
  final String questionName;
  final String difficulty;
  final String? problemStatement;
  final String? inputFormat;
  final String? outputFormat;
  final String? constraints;
  final String? explanation;
  final int points;
  final String? image;
  final Map<String, dynamic>? boilerplateCode;
  final List<dynamic>? sampleTestcases;
  final String questionStatus;

  PracticeQuestionModel({
    required this.id,
    required this.questionName,
    required this.difficulty,
    this.problemStatement,
    this.inputFormat,
    this.outputFormat,
    this.constraints,
    this.explanation,
    required this.points,
    this.image,
    this.boilerplateCode,
    this.sampleTestcases,
    required this.questionStatus,
  });

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionModel(
      id: json['id'] ?? 0,
      questionName: json['question_name'] ?? json['name'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      problemStatement: json['problem_statement'],
      inputFormat: json['input_format'],
      outputFormat: json['output_format'],
      constraints: json['constraints'],
      explanation: json['explanation'],
      points: json['points'] ?? 10,
      image: json['image'],
      boilerplateCode: json['boilerplate_code'] is Map<String, dynamic> ? json['boilerplate_code'] : null,
      sampleTestcases: json['sample_testcases'] is List ? json['sample_testcases'] : null,
      questionStatus: json['question_status'] ?? 'Solve',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_name': questionName,
      'difficulty': difficulty,
      'problem_statement': problemStatement,
      'input_format': inputFormat,
      'output_format': outputFormat,
      'constraints': constraints,
      'explanation': explanation,
      'points': points,
      'image': image,
      'boilerplate_code': boilerplateCode,
      'sample_testcases': sampleTestcases,
      'question_status': questionStatus,
    };
  }
}
