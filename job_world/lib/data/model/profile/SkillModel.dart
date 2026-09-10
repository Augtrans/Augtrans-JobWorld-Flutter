class UserSkillModel {
  final int? id;
  final int user;
  final int skill;
  final String proficiency;
  final String? lastUsed;
  final double experienceInYears;
  final String skillName;

  UserSkillModel({
    this.id,
    required this.user,
    required this.skill,
    required this.proficiency,
    this.lastUsed,
    required this.experienceInYears,
    required this.skillName,
  });

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json['id'],
      user: json['user'] ?? 0,
      skill: json['skill'] ?? 0,
      proficiency: json['proficiency'] ?? '',
      lastUsed: json['last_used'],
      experienceInYears: (json['experience_in_years'] ?? 0.0).toDouble(),
      skillName: json['skill_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user': user,
      'skill': skill,
      'proficiency': proficiency,
      'last_used': lastUsed,
      'experience_in_years': experienceInYears,
    };
  }
}

class MasterSkillModel {
  final int id;
  final String name;
  final String? category;

  MasterSkillModel({
    required this.id,
    required this.name,
    this.category,
  });

  factory MasterSkillModel.fromJson(Map<String, dynamic> json) {
    return MasterSkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
