class ChallengePackTopicArgs {
  final String sourceType; // 'MCQ' or 'CODING'
  final int id;
  final String name;

  ChallengePackTopicArgs({
    required this.sourceType,
    required this.id,
    required this.name,
  });

  bool get isMcq => sourceType.toUpperCase() == 'MCQ';
}

class ChallengePackExamsArgs {
  final int subdomainId;
  final String subdomainName;

  ChallengePackExamsArgs({
    required this.subdomainId,
    required this.subdomainName,
  });
}

class ChallengePackQuestionsArgs {
  final int subcategoryId;
  final String subcategoryName;

  ChallengePackQuestionsArgs({
    required this.subcategoryId,
    required this.subcategoryName,
  });
}
