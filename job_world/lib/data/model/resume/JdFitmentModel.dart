class JdFitmentModel {
  final int rank;
  final num maxPossibleScore;
  final List<String> evaluatedComponents;
  final bool meetsHardRequirements;
  final JdScoreBreakdownModel scoreBreakdown;
  final num yearsOfExperience;
  final JdSkillsModel skills;
  final String? matchingWords;
  final int matchingWordCount;
  final List<String> matchingKeywords;
  final List<String> strengths;
  final List<String> weaknesses;
  final String? location;
  final double fitmentScore;
  final bool lowFitmentWarning;
  final JdExtractionModel? jdExtraction;

  JdFitmentModel({
    required this.rank,
    required this.maxPossibleScore,
    required this.evaluatedComponents,
    required this.meetsHardRequirements,
    required this.scoreBreakdown,
    required this.yearsOfExperience,
    required this.skills,
    this.matchingWords,
    required this.matchingWordCount,
    required this.matchingKeywords,
    required this.strengths,
    required this.weaknesses,
    this.location,
    required this.fitmentScore,
    required this.lowFitmentWarning,
    this.jdExtraction,
  });

  factory JdFitmentModel.fromJson(Map<String, dynamic> json) {
    return JdFitmentModel(
      rank: json['rank'] ?? 0,
      maxPossibleScore: json['max_possible_score'] ?? 100,
      evaluatedComponents: (json['evaluated_components'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      meetsHardRequirements: json['meets_hard_requirements'] ?? false,
      scoreBreakdown: JdScoreBreakdownModel.fromJson(
        json['score_breakdown'] is Map<String, dynamic>
            ? json['score_breakdown']
            : {},
      ),
      yearsOfExperience: json['years_of_experience'] ?? 0,
      skills: JdSkillsModel.fromJson(
        json['skills'] is Map<String, dynamic> ? json['skills'] : {},
      ),
      matchingWords: json['matching_words'],
      matchingWordCount: json['matching_word_count'] ?? 0,
      matchingKeywords: (json['matching_keywords'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      strengths: (json['strengths'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'],
      fitmentScore: (json['fitment_score'] ?? 0.0).toDouble(),
      lowFitmentWarning: json['low_fitment_warning'] ?? false,
      jdExtraction: json['jd_extraction'] is Map<String, dynamic>
          ? JdExtractionModel.fromJson(json['jd_extraction'])
          : null,
    );
  }
}

class JdScoreBreakdownModel {
  final double skillScore;
  final double experienceScore;
  final double jdMatchScore;
  final double educationScore;
  final double locationScore;

  JdScoreBreakdownModel({
    required this.skillScore,
    required this.experienceScore,
    required this.jdMatchScore,
    required this.educationScore,
    required this.locationScore,
  });

  factory JdScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    return JdScoreBreakdownModel(
      skillScore: (json['skill_score'] ?? 0.0).toDouble(),
      experienceScore: (json['experience_score'] ?? 0.0).toDouble(),
      jdMatchScore: (json['jd_match_score'] ?? 0.0).toDouble(),
      educationScore: (json['education_score'] ?? 0.0).toDouble(),
      locationScore: (json['location_score'] ?? 0.0).toDouble(),
    );
  }
}

class JdSkillsModel {
  final List<JdSkillMatchedModel> matched;
  final List<String> missing;
  final List<JdSkillMatchedModel> all;

  JdSkillsModel({
    required this.matched,
    required this.missing,
    required this.all,
  });

  factory JdSkillsModel.fromJson(Map<String, dynamic> json) {
    return JdSkillsModel(
      matched: (json['matched'] as List?)
              ?.map((e) => JdSkillMatchedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      missing: (json['missing'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      all: (json['all'] as List?)
              ?.map((e) => JdSkillMatchedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class JdSkillMatchedModel {
  final String name;
  final String proficiency;
  final num? yoe;

  JdSkillMatchedModel({
    required this.name,
    required this.proficiency,
    this.yoe,
  });

  factory JdSkillMatchedModel.fromJson(Map<String, dynamic> json) {
    return JdSkillMatchedModel(
      name: json['name'] ?? '',
      proficiency: json['proficiency'] ?? 'Intermediate',
      yoe: json['yoe'],
    );
  }
}

class JdExtractionModel {
  final List<String> requiredSkills;
  final num minYoe;
  final List<dynamic> qualifications;
  final String? location;
  final bool allowRelocation;

  JdExtractionModel({
    required this.requiredSkills,
    required this.minYoe,
    required this.qualifications,
    this.location,
    required this.allowRelocation,
  });

  factory JdExtractionModel.fromJson(Map<String, dynamic> json) {
    return JdExtractionModel(
      requiredSkills: (json['required_skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      minYoe: json['min_yoe'] ?? 0,
      qualifications: (json['qualifications'] as List?) ?? [],
      location: json['location'],
      allowRelocation: json['allow_relocation'] ?? false,
    );
  }
}
