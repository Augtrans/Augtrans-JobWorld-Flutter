class UserRegisterReqModel {
  final String username;
  final String email;
  final String password;
  final int department;
  final int role;
  final dynamic organization; // Can be int (ID) or String (Name)
  final int? reportingManager;

  UserRegisterReqModel({
    required this.username,
    required this.email,
    required this.password,
    required this.department,
    required this.role,
    required this.organization,
    this.reportingManager,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'department': department,
      'role': role,
      'organization': organization,
      'reporting_manager': reportingManager,
    };
  }
}
