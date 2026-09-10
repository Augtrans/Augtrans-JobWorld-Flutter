class UserProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? addressLine;
  final String city;
  final String state;
  final String? country;
  final String pincode;
  final String? profilePicture;
  final double currentCtc;
  final double expectedCtc;
  final String noticePeriod;
  final String phoneNumber;
  final String? profileSummary;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final double yearsOfExperience;
  final String? candidateType;
  final String createdAt;
  final int user;

  UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.addressLine,
    required this.city,
    required this.state,
    this.country,
    required this.pincode,
    this.profilePicture,
    required this.currentCtc,
    required this.expectedCtc,
    required this.noticePeriod,
    required this.phoneNumber,
    this.profileSummary,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    required this.yearsOfExperience,
    this.candidateType,
    required this.createdAt,
    required this.user,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      addressLine: json['address_line'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'],
      pincode: json['pincode'] ?? '',
      profilePicture: json['profile_picture'],
      currentCtc: (json['current_ctc'] ?? 0.0).toDouble(),
      expectedCtc: (json['expected_ctc'] ?? 0.0).toDouble(),
      noticePeriod: json['notice_period'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profileSummary: json['profile_summary'],
      linkedinUrl: json['linkedin_url'],
      githubUrl: json['github_url'],
      portfolioUrl: json['portfolio_url'],
      yearsOfExperience: (json['years_of_experience'] ?? 0.0).toDouble(),
      candidateType: json['candidate_type'],
      createdAt: json['created_at'] ?? '',
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'profile_picture': profilePicture,
      'current_ctc': currentCtc,
      'expected_ctc': expectedCtc,
      'notice_period': noticePeriod,
      'phone_number': phoneNumber,
      'profile_summary': profileSummary,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'years_of_experience': yearsOfExperience,
      'candidate_type': candidateType,
      'created_at': createdAt,
      'user': user,
    };
  }
}
