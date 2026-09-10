class CvModel {
  final int id;
  final int candidate;
  final String sourceType;
  final dynamic template;
  final int version;
  final CvData cvData;
  final String? pdfFile;
  final bool isActive;
  final String createdAt;

  CvModel({
    required this.id,
    required this.candidate,
    required this.sourceType,
    this.template,
    required this.version,
    required this.cvData,
    this.pdfFile,
    required this.isActive,
    required this.createdAt,
  });

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] ?? 0,
      candidate: json['candidate'] ?? 0,
      sourceType: json['source_type'] ?? '',
      template: json['template'],
      version: json['version'] ?? 1,
      cvData: CvData.fromJson(json['cv_data'] ?? {}),
      pdfFile: json['pdf_file'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class CvData {
  final List<CvSkill> skills;
  final List<CvProject> projects;
  final List<CvEducation> education;
  final List<CvExperience> experience;
  final List<CvCertification> certifications;
  final CvPersonalInfo? personalInfo;

  CvData({
    required this.skills,
    required this.projects,
    required this.education,
    required this.experience,
    required this.certifications,
    this.personalInfo,
  });

  factory CvData.fromJson(Map<String, dynamic> json) {
    return CvData(
      skills: (json['skills'] as List?)?.map((e) => CvSkill.fromJson(e)).toList() ?? <CvSkill>[],
      projects: (json['projects'] as List?)?.map((e) => CvProject.fromJson(e)).toList() ?? <CvProject>[],
      education: (json['education'] as List?)?.map((e) => CvEducation.fromJson(e)).toList() ?? <CvEducation>[],
      experience: (json['experience'] as List?)?.map((e) => CvExperience.fromJson(e)).toList() ?? <CvExperience>[],
      certifications: (json['certifications'] as List?)?.map((e) => CvCertification.fromJson(e)).toList() ?? <CvCertification>[],
      personalInfo: json['personal_info'] != null ? CvPersonalInfo.fromJson(json['personal_info']) : null,
    );
  }
}

class CvCertification {
  final String name;
  final String? issuingOrganization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialId;

  CvCertification({
    required this.name,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
  });

  factory CvCertification.fromJson(Map<String, dynamic> json) {
    return CvCertification(
      name: json['name'] ?? '',
      issuingOrganization: json['issuing_organization'],
      issueDate: json['issue_date'],
      expiryDate: json['expiry_date'],
      credentialId: json['credential_id'],
    );
  }
}

class CvSkill {
  final String name;
  final String proficiency;
  final double experienceInYears;

  CvSkill({
    required this.name,
    required this.proficiency,
    required this.experienceInYears,
  });

  factory CvSkill.fromJson(Map<String, dynamic> json) {
    return CvSkill(
      name: json['name'] ?? '',
      proficiency: json['proficiency'] ?? '',
      experienceInYears: (json['experience_in_years'] ?? 0.0).toDouble(),
    );
  }
}

class CvProject {
  final String title;
  final String description;
  final List<String> skillsUsed;
  final String projectStatus;

  CvProject({
    required this.title,
    required this.description,
    required this.skillsUsed,
    required this.projectStatus,
  });

  factory CvProject.fromJson(Map<String, dynamic> json) {
    return CvProject(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      skillsUsed: (json['skills_used'] as List?)?.map((e) => e.toString()).toList() ?? [],
      projectStatus: json['project_status'] ?? '',
    );
  }
}

class CvEducation {
  final String course;
  final int? endYear;
  final int? startYear;
  final String university;
  final String institution;
  final double marks;

  CvEducation({
    required this.course,
    this.endYear,
    this.startYear,
    required this.university,
    required this.institution,
    required this.marks,
  });

  factory CvEducation.fromJson(Map<String, dynamic> json) {
    return CvEducation(
      course: json['course'] ?? '',
      endYear: json['end_year'],
      startYear: json['start_year'],
      university: json['university'] ?? '',
      institution: json['institution'] ?? '',
      marks: (json['marks'] ?? 0.0).toDouble(),
    );
  }
}

class CvExperience {
  final String designation;
  final String jobProfile;
  final String joinedDate;
  final String workedTill;
  final String organizationName;

  CvExperience({
    required this.designation,
    required this.jobProfile,
    required this.joinedDate,
    required this.workedTill,
    required this.organizationName,
  });

  factory CvExperience.fromJson(Map<String, dynamic> json) {
    return CvExperience(
      designation: json['designation'] ?? '',
      jobProfile: json['job_profile'] ?? '',
      joinedDate: json['joined_date'] ?? '',
      workedTill: json['worked_till'] ?? '',
      organizationName: json['organization_name'] ?? '',
    );
  }
}

class CvPersonalInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String profileSummary;

  CvPersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.profileSummary,
  });

  factory CvPersonalInfo.fromJson(Map<String, dynamic> json) {
    return CvPersonalInfo(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileSummary: json['profile_summary'] ?? '',
    );
  }
}
