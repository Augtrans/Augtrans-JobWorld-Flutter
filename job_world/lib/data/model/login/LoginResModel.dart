class LoginResponseModel {
  final String refresh;
  final String access;
  final User user;

  LoginResponseModel({
    required this.refresh,
    required this.access,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      refresh: json['refresh'] ?? '',
      access: json['access'] ?? '',
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final int role;
  final String roleName;
  final int organization;
  final int department;
  final String organizationName;
  final bool isApproved;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.roleName,
    required this.organization,
    required this.department,
    required this.organizationName,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 0,
      roleName: json['role_name'] ?? '',
      organization: json['organization'] ?? 0,
      department: json['department'] ?? 0,
      organizationName: json['organization_name'] ?? '',
      isApproved: json['is_approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'role_name': roleName,
      'department': department,
      'organization': organization,
      'organization_name': organizationName,
      'is_approved': isApproved,
    };
  }
}